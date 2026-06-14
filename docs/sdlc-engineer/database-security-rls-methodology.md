# Database Security / Row-Level Security Methodology — Best Practices

## Design Principles

1. **RLS is defense in depth, not the only defense** — API-layer authorization and database-layer RLS work together. Never rely on RLS alone. Always validate at the API layer too.
2. **Deny by default** — When RLS is enabled on a table with no policies, all access is denied. This is the safest starting state.
3. **Role-based policy gating** — Always specify `TO authenticated` or `TO anon` on each policy. This prevents the policy expression from running for unintended roles.
4. **Least privilege for database roles** — The `anon` role should have only the bare minimum permissions. The `service_role` bypasses RLS — never expose its credentials to clients.
5. **Performance-aware policy design** — Unoptimized RLS policies can degrade query performance by 99%+. Index policy columns and use subquery wrapping.

## When to Apply

- Every table in an exposed schema (public) MUST have RLS enabled
- When storing user-owned data, organization-owned data, or tenant-partitioned data
- When building multi-tenant applications where data isolation is required
- When using Supabase or any Postgres-based backend-as-a-service
- When users access the database directly from client-side code (e.g., Supabase client)

## Process

### Phase 1: Enable RLS on Every User-Data Table

```sql
-- Enable RLS on an existing table
ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

-- Grant minimal permissions
GRANT SELECT ON table_name TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON table_name TO authenticated;
-- NEVER grant to service_role from client-side — service_role bypasses RLS
```

**Auto-enable RLS for new tables (Postgres event trigger):**
```sql
CREATE OR REPLACE FUNCTION rls_auto_enable()
RETURNS EVENT_TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = pg_catalog AS $$
BEGIN
  EXECUTE format('ALTER TABLE IF EXISTS %s ENABLE ROW LEVEL SECURITY',
    (SELECT object_identity FROM pg_event_trigger_ddl_commands()
     WHERE command_tag IN ('CREATE TABLE') AND object_type IN ('table')));
END;
$$;

CREATE EVENT TRIGGER ensure_rls ON ddl_command_end
WHEN TAG IN ('CREATE TABLE', 'CREATE TABLE AS')
EXECUTE FUNCTION rls_auto_enable();
```

### Phase 2: Define the Ownership Model

Before writing policies, determine the ownership structure:

| Model | Pattern | Example |
|-------|---------|---------|
| User-owned | Each row belongs to one user | `todos.user_id = auth.uid()` |
| Organization-owned | Users share access via organization | `docs.org_id IN (user_orgs())` |
| Role-based | Access depends on user role within context | `projects WHERE can_access(role, project_id)` |
| Public-read, owner-write | Everyone can read, only owner can modify | `SELECT: true; UPDATE: user_id = auth.uid()` |

**Identify ownership fields:**
```bash
# Find ownership fields on models
grep -rn "owner\|user_id\|organization\|tenant" --include="models.py" --include="schema.prisma"
```

### Phase 3: Create Policies Per Operation

**SELECT policies — rows the user can see:**
```sql
-- User can only see their own records
CREATE POLICY "user_select_own" ON todos FOR SELECT
TO authenticated
USING ((SELECT auth.uid()) = user_id);

-- Everyone (including anonymous) can see public records
CREATE POLICY "public_select" ON products FOR SELECT
TO anon, authenticated
USING (is_published = true);
```

**INSERT policies — rows the user can create:**
```sql
-- User can only create records with their own user_id
CREATE POLICY "user_insert_own" ON todos FOR INSERT
TO authenticated
WITH CHECK ((SELECT auth.uid()) = user_id);

-- DO NOT allow setting user_id from request body
-- WRONG: WITH CHECK (true)  — user can set any user_id
-- CORRECT: WITH CHECK ((SELECT auth.uid()) = user_id)
```

**UPDATE policies — rows the user can modify:**
```sql
-- User can only update their own records
CREATE POLICY "user_update_own" ON todos FOR UPDATE
TO authenticated
USING ((SELECT auth.uid()) = user_id)           -- existing row must match
WITH CHECK ((SELECT auth.uid()) = user_id);     -- new row must also match
```

**DELETE policies — rows the user can delete:**
```sql
-- User can only delete their own records
CREATE POLICY "user_delete_own" ON todos FOR DELETE
TO authenticated
USING ((SELECT auth.uid()) = user_id);
```

### Phase 4: Multi-Tenant RLS

**Organization-scoped access:**
```sql
-- Users belong to teams/organizations
-- teams table: id, name
-- team_members table: team_id, user_id

-- Organization-scoped SELECT
CREATE POLICY "team_select" ON team_docs FOR SELECT
TO authenticated
USING (
  team_id IN (
    SELECT team_id FROM team_members
    WHERE user_id = (SELECT auth.uid())
  )
);

-- Admin override within org
CREATE POLICY "admin_all" ON team_docs FOR ALL
TO authenticated
USING (
  (SELECT auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
  AND team_id IN (
    SELECT team_id FROM team_members
    WHERE user_id = (SELECT auth.uid())
  )
);
```

**Using `auth.jwt()` for claims-based access:**
```sql
-- Store team memberships in app_metadata (can't be modified by user)
-- JWT contains: { app_metadata: { teams: ['team-a', 'team-b'] } }

CREATE POLICY "jwt_team_access" ON team_docs FOR SELECT
TO authenticated
USING (
  team_id IN (
    SELECT jsonb_array_elements_text(
      (SELECT auth.jwt() -> 'app_metadata' -> 'teams')
    )
  )
);
```

### Phase 5: Performance Optimization

RLS policies execute on every row. For large tables, optimize aggressively:

**Rule 1: Add indexes on policy columns:**
```sql
-- If policy filters on user_id
CREATE INDEX idx_todos_user_id ON todos USING btree (user_id);

-- If policy filters on org_id
CREATE INDEX idx_docs_org_id ON docs USING btree (org_id);
```

**Rule 2: Wrap function calls with `SELECT`:**
```sql
-- SLOW (row-by-row): auth.uid() called for every row
-- POLICY: USING (auth.uid() = user_id)

-- FAST (cached once): auth.uid() called once per query
-- POLICY: USING ((SELECT auth.uid()) = user_id)
```

**Rule 3: Add explicit filters in queries (even though RLS duplicates them):**
```sql
-- DON'T:
SELECT * FROM todos;

-- DO:
SELECT * FROM todos WHERE user_id = 'current-user-id';
-- Postgres can use the explicit WHERE to construct a better plan
```

**Rule 4: Minimize joins in policy expressions:**
```sql
-- SLOW: Join in policy
CREATE POLICY "slow" ON source_table
USING (
  auth.uid() IN (
    SELECT user_id FROM team_user
    WHERE team_user.team_id = source_table.team_id  -- join to source
  )
);

-- FAST: Subquery without join
CREATE POLICY "fast" ON source_table
USING (
  team_id IN (
    SELECT team_id FROM team_user
    WHERE user_id = (SELECT auth.uid())  -- no join to source
  )
);
```

**Rule 5: Use `security definer` functions for complex lookups:**
```sql
-- Slow: RLS checked on joined table
CREATE POLICY "slow_join" ON main_table
USING (
  EXISTS (
    SELECT 1 FROM roles_table
    WHERE auth.uid() = user_id AND role = 'admin'
  )
);

-- Fast: bypass RLS on roles_table via security definer
CREATE FUNCTION private.is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER  -- runs as creator (bypasses RLS)
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM roles_table
    WHERE auth.uid() = user_id AND role = 'admin'
  );
END;
$$;

CREATE POLICY "fast_nojoin" ON main_table
USING ((SELECT private.is_admin()));
```

### Phase 6: Views and RLS

Views bypass RLS by default (they execute as the view creator):

```sql
-- Postgres 15+: Make views respect RLS
CREATE VIEW user_profiles
WITH (security_invoker = true)
AS SELECT * FROM profiles;

-- Older Postgres: Revoke direct access
REVOKE ALL ON user_profiles FROM anon, authenticated;
-- And expose only via functions or API
```

### Phase 7: Test RLS Policies

```sql
-- Test as specific user
SET ROLE authenticated;
SELECT auth.uid();  -- verify context

-- Test SELECT
SELECT * FROM todos;

-- Test INSERT
INSERT INTO todos (user_id, title) VALUES ('other-user-uuid', 'test');
-- Should FAIL if policy checks ownership

-- Test UPDATE
UPDATE todos SET title = 'hacked' WHERE user_id != auth.uid();
-- Should affect 0 rows

-- Test DELETE
DELETE FROM todos WHERE user_id != auth.uid();
-- Should affect 0 rows

-- Reset
RESET ROLE;
```

**RLS coverage test pattern:**
```sql
-- Verify all user-data tables have RLS enabled
SELECT schemaname, tablename, rowsecurity
FROM pg_catalog.pg_tables
WHERE schemaname = 'public'
  AND tablename NOT IN ('_prisma_migrations')  -- exclude framework tables
ORDER BY tablename;

-- Expected: all tables show rowsecurity = true
```

### Phase 8: Supabase-Specific Patterns

**Helper functions available in Supabase:**

| Function | Returns | Use |
|----------|---------|-----|
| `auth.uid()` | UUID | Current user's ID. Wrap as `(SELECT auth.uid())` for performance. |
| `auth.jwt()` | JSON | Current user's JWT claims. Use `app_metadata` (user can't modify). |
| `auth.role()` | TEXT | `authenticated` or `anon`. |

**Common Supabase RLS patterns:**
```sql
-- Pattern 1: User-specific access
CREATE POLICY "user_data" ON profiles FOR ALL
TO authenticated
USING ((SELECT auth.uid()) = id);

-- Pattern 2: Admin has full access
CREATE POLICY "admin_override" ON profiles FOR ALL
TO authenticated
USING (
  (SELECT auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

-- Pattern 3: MFA required for sensitive operations
CREATE POLICY "mfa_required_update" ON profiles FOR UPDATE
AS RESTRICTIVE
TO authenticated
USING (
  (SELECT auth.jwt() ->> 'aal') = 'aal2'
);
```

## Anti-patterns

- **RLS without indexes** — A policy on `user_id` without an index on `user_id` will scan every row. Add indexes.
- **`auth.uid()` without wrapping** — `auth.uid()` (a STABLE function) is called row-by-row without `SELECT` wrapping. Use `(SELECT auth.uid())` to cache it.
- **Forgetting `TO` role** — A policy without `TO authenticated` runs for `anon` users too, wasting compute.
- **Views without `security_invoker`** — Traditional views bypass RLS, creating a data leak. Always use `security_invoker = true`.
- **Storing auth data in `raw_user_meta_data`** — Users can modify their own `raw_user_meta_data`. Use `raw_app_meta_data` for authorization claims.
- **Bypassing RLS with `service_role` from client** — Never use the `service_role` key client-side. It bypasses ALL RLS.
- **RLS as the only auth layer** — RLS is defense in depth. The API layer must also authorize every request.
- **No testing of RLS policies** — RLS policies are code. Test them with pgTAP or integration tests.
- **Backup/restore without RLS** — Backups may bypass RLS if the backup user has `BYPASSRLS`. Verify backup integrity.
- **Race conditions in policy subqueries** — Subqueries in RLS policies that read from other tables can have race conditions. Use `FOR SHARE` or `SECURITY DEFINER` functions.

## Tools with Install Commands

```bash
# PostgreSQL RLS verification query
psql -d mydb -c "
  SELECT schemaname, tablename, rowsecurity
  FROM pg_catalog.pg_tables
  WHERE schemaname = 'public'
    AND rowsecurity = false;
"

# pgTAP — RLS policy testing framework
# Install: https://pgtap.org/
# Example: test that RLS prevents cross-user access

# Supabase CLI — local development + RLS testing
npm install -g supabase
supabase start
supabase db test

# PostgreSQL docs: Row Security Policies
# https://www.postgresql.org/docs/current/ddl-rowsecurity.html

# Supabase RLS Guide
# https://supabase.com/docs/guides/auth/row-level-security
```
