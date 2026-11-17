import 'interview_question.dart';

final List<InterviewQuestion> sqlInterviewQuestions = buildInterviewQuestions(
  subject: 'SQL / Database Management',
  idPrefix: 'sql',
  basic: [
    questionDraft(r'''What is the difference between a table row and a column?''', r'''A table stores records in rows and defines named columns that describe each record's attributes. A column has a type and constraints, while each row contains one value for each column, subject to nullability and defaults.''', r'''An Employees table can have one row per employee and columns for employee_id, name, and hire_date.''', r'''This model represents structured entities and enables consistent querying across records.''', r'''Rows are records; columns are attributes; types and constraints govern stored values.''', code: r'''SELECT employee_id, name
FROM Employees;'''),
    questionDraft(r'''What does a primary key guarantee?''', r'''A primary key uniquely identifies each row and cannot contain NULL values. A table has one primary-key constraint, which can consist of multiple columns when the combined values define uniqueness.''', r'''An Orders table can use order_id as its primary key even when customers place many orders.''', r'''Stable row identifiers support references, updates, and reliable joins.''', r'''Unique and non-null; one constraint per table; can be composite.''', code: r'''CREATE TABLE Orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL
);'''),
    questionDraft(r'''What is a foreign key used for?''', r'''A foreign key requires referenced values to match a candidate key in another table, or be NULL when allowed. It enforces referential integrity; configured delete or update actions define what happens to dependent rows.''', r'''Orders.customer_id references Customers.customer_id so an order cannot point to a nonexistent customer.''', r'''Foreign keys protect relationships from orphan records and invalid references.''', r'''References unique/primary key; nullable behavior depends on schema; actions include RESTRICT, CASCADE, SET NULL.''', code: r'''CREATE TABLE Orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES Customers(customer_id)
);'''),
    questionDraft(r'''How does SELECT retrieve data?''', r'''SELECT specifies expressions or columns to return, and FROM identifies the row source. A query can project chosen columns and optionally filter, group, sort, or limit its results.''', r'''Retrieve product names and prices without exposing internal inventory fields.''', r'''Projection reduces returned data and limits unnecessary disclosure or transfer.''', r'''Select explicit columns; FROM names source; aliases improve result labels.''', code: r'''SELECT product_name, price
FROM Products;'''),
    questionDraft(r'''How does WHERE filter rows?''', r'''WHERE evaluates a predicate for each candidate row and retains rows for which the predicate is TRUE. SQL uses three-valued logic, so a predicate evaluating to UNKNOWN, often due to NULL, is not retained.''', r'''Return only products whose price is greater than 20.''', r'''Row filtering limits results before aggregation and supports targeted reports.''', r'''WHERE filters rows; NULL comparisons become UNKNOWN; use IS NULL for null checks.''', code: r'''SELECT product_name
FROM Products
WHERE price > 20;'''),
    questionDraft(r'''How does ORDER BY determine result order?''', r'''ORDER BY sorts the final result according to one or more expressions, ascending by default or descending with DESC. Without ORDER BY, SQL does not guarantee row order, even if a query repeatedly appears to return the same sequence.''', r'''Sort invoices newest first and break timestamp ties by invoice_id.''', r'''Deterministic ordering is necessary for reports, pagination, and reproducible output.''', r'''Order not guaranteed absent ORDER BY; specify tie-breakers; NULL ordering varies by dialect.''', code: r'''SELECT invoice_id, created_at
FROM Invoices
ORDER BY created_at DESC, invoice_id;'''),
    questionDraft(r'''What does DISTINCT do in a query?''', r'''DISTINCT removes duplicate result rows based on all selected expressions, not merely one arbitrarily chosen column. It can require sorting or hashing, so it should express a genuine uniqueness requirement rather than conceal an incorrect join.''', r'''List each region represented in the Customers table once.''', r'''Distinct values are useful in category lists and deduplicated reporting.''', r'''Applies to selected row; multiple columns considered together; can add query cost.''', code: r'''SELECT DISTINCT region
FROM Customers;'''),
    questionDraft(r'''How does SQL handle NULL values?''', r'''NULL represents missing or unknown information and is not equal to any value, including another NULL. Comparisons involving NULL generally evaluate to UNKNOWN; use IS NULL or IS NOT NULL and account for NULL propagation in expressions and aggregates.''', r'''A nullable shipped_at column identifies orders that have not yet shipped with `shipped_at IS NULL`.''', r'''Correct NULL handling prevents missing data from being mistaken for a normal value.''', r'''Three-valued logic; use IS NULL; COUNT(column) skips nulls while COUNT(*) counts rows.''', code: r'''SELECT order_id
FROM Orders
WHERE shipped_at IS NULL;'''),
    questionDraft(r'''What is the difference between COUNT(*) and COUNT(column)?''', r'''COUNT(*) counts every row in the group, including rows where individual columns are NULL. COUNT(column) counts only rows whose specified expression is not NULL.''', r'''For five customer rows where one email is absent, COUNT(*) is five while COUNT(email) is four.''', r'''Use the form matching whether the question concerns rows or present values.''', r'''COUNT(*) counts rows; COUNT(expr) excludes null expr; COUNT(DISTINCT expr) counts unique non-null values.''', code: r'''SELECT COUNT(*) AS all_rows, COUNT(email) AS known_emails
FROM Customers;'''),
    questionDraft(r'''How is LIKE used for pattern matching?''', r'''LIKE compares a character expression to a pattern where `%` matches zero or more characters and `_` matches one character. Case sensitivity and escape syntax can vary with collation and database dialect.''', r'''Find customers whose email ends in `example.org` with a pattern such as `%@example.org`.''', r'''Pattern filters are useful for simple prefix, suffix, and substring searches.''', r'''Percent matches many; underscore matches one; collation controls case behavior; escape wildcard literals as needed.''', code: r'''SELECT email
FROM Customers
WHERE email LIKE '%@example.org';'''),
    questionDraft(r'''What is the purpose of the IN predicate?''', r'''IN tests whether an expression matches any value in a specified list or subquery result. It is often clearer than a series of OR comparisons, but a NULL in a NOT IN set can produce UNKNOWN and unexpectedly filter rows.''', r'''Select tickets with status equal to Open, Pending, or Escalated.''', r'''IN expresses membership filters for finite categories or query-derived sets.''', r'''Equivalent to membership checks; subquery supported; handle NULL carefully with NOT IN.''', code: r'''SELECT ticket_id
FROM Tickets
WHERE status IN ('Open', 'Pending', 'Escalated');'''),
    questionDraft(r'''How do BETWEEN bounds work?''', r'''BETWEEN tests whether a value lies within an inclusive lower and upper bound, equivalent to `>= lower AND <= upper`. It can also be used with dates or strings, whose ordering follows the database's type and collation semantics.''', r'''Filter transaction amounts from 10 through 50, including both endpoints.''', r'''Inclusive ranges are useful for numeric thresholds and appropriately bounded date-time values.''', r'''Both bounds inclusive; expressions can be UNKNOWN with NULL; be careful with end-of-day timestamp ranges.''', code: r'''SELECT transaction_id
FROM Transactions
WHERE amount BETWEEN 10 AND 50;'''),
    questionDraft(r'''What is an aggregate function?''', r'''An aggregate function computes one result from multiple input rows, such as SUM, AVG, MIN, MAX, or COUNT. In grouped queries it computes one result per group, and most aggregates ignore NULL inputs except COUNT(*).''', r'''Calculate total sales revenue across all invoice lines.''', r'''Aggregates summarize operational data for dashboards and reports.''', r'''Aggregate over rows/groups; null behavior matters; nonaggregated selected columns need grouping or valid functional dependency.''', code: r'''SELECT SUM(line_total) AS revenue
FROM InvoiceLines;'''),
    questionDraft(r'''How does GROUP BY change query results?''', r'''GROUP BY partitions rows into groups sharing the same grouping expression values, after which aggregates can summarize each group. Selected expressions generally must be grouped or aggregated, subject to database-specific functional-dependency rules.''', r'''Count orders separately for each customer_id.''', r'''Grouping supports per-category metrics and summaries.''', r'''Forms groups; NULL grouping values form a group; filter aggregates with HAVING.''', code: r'''SELECT customer_id, COUNT(*) AS order_count
FROM Orders
GROUP BY customer_id;'''),
    questionDraft(r'''What is the difference between WHERE and HAVING?''', r'''WHERE filters individual input rows before grouping and aggregation. HAVING filters groups after GROUP BY, often using aggregate expressions.''', r'''Use WHERE to consider only completed orders, then HAVING to retain customers with at least five such orders.''', r'''Separating row and group conditions keeps aggregate queries correct and efficient.''', r'''WHERE precedes groups; HAVING filters groups; do not put aggregate predicates in WHERE.''', code: r'''SELECT customer_id, COUNT(*) AS completed_count
FROM Orders
WHERE status = 'complete'
GROUP BY customer_id
HAVING COUNT(*) >= 5;'''),
    questionDraft(r'''What does an INNER JOIN return?''', r'''An INNER JOIN returns combinations of rows whose join condition evaluates to TRUE, excluding unmatched rows on either side. Multiple matching rows produce multiple result rows, so key uniqueness determines whether the join preserves a one-to-one relationship.''', r'''Join each order to its customer using the customer_id foreign key.''', r'''Inner joins combine related records when only matched entities are needed.''', r'''Only matches retained; join predicate defines relationships; duplicates may multiply rows.''', code: r'''SELECT o.order_id, c.name
FROM Orders AS o
JOIN Customers AS c ON c.customer_id = o.customer_id;'''),
    questionDraft(r'''How does a LEFT JOIN preserve unmatched rows?''', r'''A LEFT JOIN returns all rows from its left input and matching right-side rows; for unmatched left rows, right-side columns are filled with NULL. Conditions on the right table placed in WHERE can then remove those rows and unintentionally turn the result into inner-join behavior.''', r'''List all customers, including those with no orders, by left joining Orders.''', r'''Outer joins reveal missing relationships and preserve entities with no related records.''', r'''Left side preserved; unmatched right values NULL; place optional-side restrictions thoughtfully.''', code: r'''SELECT c.customer_id, o.order_id
FROM Customers AS c
LEFT JOIN Orders AS o ON o.customer_id = c.customer_id;'''),
    questionDraft(r'''What is a UNIQUE constraint?''', r'''A UNIQUE constraint prevents duplicate key values across rows, and may cover one or several columns. Treatment of NULL values in unique constraints varies by database, so nullable uniqueness requirements should be verified for the target product.''', r'''Require each user account to have a unique username.''', r'''Uniqueness constraints enforce business identifiers beyond the primary key.''', r'''Single or composite; database NULL semantics vary; indexes often implement uniqueness.''', code: r'''CREATE TABLE Users (
  user_id INTEGER PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE
);'''),
    questionDraft(r'''What does NOT NULL enforce?''', r'''A NOT NULL constraint disallows a column value from being NULL for every stored row. It does not by itself ensure that a text value is non-empty or that a number falls in an acceptable range.''', r'''A required order_date column must be present on every order row.''', r'''NOT NULL enforces the presence of mandatory data at the database boundary.''', r'''Rejects NULL; does not reject blank strings or zero; pair with CHECK when needed.''', code: r'''CREATE TABLE Orders (
  order_id INTEGER PRIMARY KEY,
  order_date DATE NOT NULL
);'''),
    questionDraft(r'''What is the role of a CHECK constraint?''', r'''A CHECK constraint requires a Boolean condition to be satisfied by inserted or updated row values, with details of UNKNOWN handling defined by the database standard/product. It is useful for row-local rules, though cross-row rules generally need other mechanisms.''', r'''Require a discount percentage to fall between zero and one hundred.''', r'''Database constraints protect invariants even when data is written by different applications.''', r'''Row-level predicate; NULL handling matters; use suitable constraints for cross-row integrity.''', code: r'''CREATE TABLE Discount (
  percent DECIMAL(5,2) CHECK (percent >= 0 AND percent <= 100)
);'''),
  ],
  intermediate: [
    questionDraft(r'''How does a FULL OUTER JOIN differ from a LEFT JOIN?''', r'''A FULL OUTER JOIN preserves unmatched rows from both inputs, filling the opposite side's columns with NULL, while a LEFT JOIN preserves only its left input. Some database systems do not support FULL OUTER JOIN directly and require an equivalent construction.''', r'''Reconcile two customer registries and display records that exist in only one registry as well as matches.''', r'''Full joins support data reconciliation and completeness comparisons.''', r'''Preserves both sides; unmatched columns become NULL; support is dialect-dependent.''', code: r'''SELECT a.customer_id, b.customer_id
FROM RegistryA AS a
FULL OUTER JOIN RegistryB AS b
  ON b.customer_id = a.customer_id;'''),
    questionDraft(r'''How can an EXISTS predicate express a relationship?''', r'''EXISTS is true when its correlated subquery returns at least one row and false when it returns none. It tests existence without requiring values from the subquery in the result and can avoid duplicate outer rows that a direct join might create.''', r'''Find customers that have placed at least one order.''', r'''Existence checks are useful for membership and anti-join logic.''', r'''Boolean existence; correlated reference; does not multiply outer rows.''', code: r'''SELECT c.customer_id
FROM Customers AS c
WHERE EXISTS (
  SELECT 1 FROM Orders AS o
  WHERE o.customer_id = c.customer_id
);'''),
    questionDraft(r'''How do NOT EXISTS and NOT IN behave with NULLs?''', r'''NOT EXISTS checks whether a correlated subquery has no matching row and is typically robust in the presence of NULL values in unrelated subquery columns. NOT IN can evaluate to UNKNOWN if its set contains NULL, causing rows that appear unmatched to be filtered out.''', r'''Find products with no sales using a correlated NOT EXISTS instead of a nullable `NOT IN` list.''', r'''Anti-joins often need null-safe semantics, especially when source data is incomplete.''', r'''NOT IN + NULL yields UNKNOWN; NOT EXISTS tests matches; define intended null equality semantics.''', code: r'''SELECT p.product_id
FROM Products AS p
WHERE NOT EXISTS (
  SELECT 1 FROM Sales AS s
  WHERE s.product_id = p.product_id
);'''),
    questionDraft(r'''How does UNION differ from UNION ALL?''', r'''UNION combines compatible result sets and removes duplicate rows, whereas UNION ALL retains every row including duplicates. Duplicate elimination can require additional work, so use UNION ALL when duplicates are meaningful or already excluded.''', r'''Append current and archived event rows with UNION ALL when both sources are disjoint by design.''', r'''Set operators combine similarly shaped results from separate query branches.''', r'''Same number of columns and compatible types; UNION deduplicates; UNION ALL preserves multiplicity.''', code: r'''SELECT event_id FROM CurrentEvents
UNION ALL
SELECT event_id FROM ArchivedEvents;'''),
    questionDraft(r'''What is a common table expression?''', r'''A common table expression (CTE), declared with WITH, names a query expression for use within a single statement. It can improve organization and support recursion, but it does not guarantee materialization or a performance improvement; optimizer behavior is database-specific.''', r'''Name a filtered set of recent orders and then aggregate that set by customer.''', r'''CTEs make complex statements easier to structure and review.''', r'''Statement-scoped name; may be recursive; materialization and optimization vary by product.''', code: r'''WITH Recent AS (
  SELECT order_id, customer_id
  FROM Orders
  WHERE order_date >= DATE '2026-01-01'
)
SELECT customer_id, COUNT(*)
FROM Recent
GROUP BY customer_id;'''),
    questionDraft(r'''How do window functions differ from GROUP BY aggregates?''', r'''Window functions calculate across a related set of rows while retaining each input row in the output, unlike GROUP BY which collapses rows into groups. An OVER clause defines partitioning and ordering, with an optional frame specifying the rows used for each result.''', r'''Show each employee's salary alongside the average salary for their department.''', r'''Window calculations enable rankings, running totals, and comparisons without losing row-level detail.''', r'''OVER defines window; partition keeps groups; rows remain; frame semantics matter.''', code: r'''SELECT employee_id, department_id, salary,
       AVG(salary) OVER (PARTITION BY department_id) AS dept_avg
FROM Employees;'''),
    questionDraft(r'''What does ROW_NUMBER calculate?''', r'''ROW_NUMBER assigns a sequential integer to rows within each window partition according to the specified ordering. If the ordering columns tie, the relative assignment is nondeterministic unless additional tie-breaker columns are supplied.''', r'''Number each customer's orders from newest to oldest to select the latest one.''', r'''Row numbering supports deduplication, pagination strategies, and top-per-group selection.''', r'''Starts at one per partition; order required for meaningful sequence; make ties deterministic.''', code: r'''SELECT customer_id, order_id,
       ROW_NUMBER() OVER (
         PARTITION BY customer_id
         ORDER BY order_date DESC, order_id DESC
       ) AS rn
FROM Orders;'''),
    questionDraft(r'''How do RANK and DENSE_RANK treat ties?''', r'''RANK assigns the same rank to tied values and leaves gaps after ties, while DENSE_RANK assigns the same rank but continues without gaps. Both operate within partitions and ordering defined by the window.''', r'''Scores 100, 100, and 90 receive ranks 1, 1, 3 with RANK, but 1, 1, 2 with DENSE_RANK.''', r'''Choose ranking behavior based on whether tied positions should create gaps.''', r'''Ties share rank; RANK gaps; DENSE_RANK has no gaps; ORDER BY defines ties.''', code: r'''SELECT score,
       RANK() OVER (ORDER BY score DESC) AS r,
       DENSE_RANK() OVER (ORDER BY score DESC) AS dr
FROM ExamResults;'''),
    questionDraft(r'''What is a window frame and why does it matter?''', r'''A window frame defines which rows around the current row contribute to a frame-sensitive window calculation, such as a moving sum. Defaults can differ based on ordering and database behavior, so explicit ROWS or RANGE boundaries make intended running or rolling logic clear.''', r'''Compute a three-transaction rolling total using the current row and two preceding rows.''', r'''Frames make time-series and cumulative metrics precise, particularly when order values tie.''', r'''ROWS counts physical rows; RANGE uses ordering values/peers; specify boundaries explicitly.''', code: r'''SELECT account_id, txn_date, amount,
       SUM(amount) OVER (
         PARTITION BY account_id
         ORDER BY txn_date
         ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ) AS rolling_total
FROM Transactions;'''),
    questionDraft(r'''How does CASE implement conditional expressions?''', r'''CASE evaluates conditions in order and returns the result for the first matching WHEN branch, with an optional ELSE fallback. It can be used in SELECT, ORDER BY, and other expressions, and all result branches must resolve to compatible types.''', r'''Label an invoice as overdue when its due date precedes today and it remains unpaid.''', r'''Conditional expressions enable bucketing, custom labels, and controlled computed values.''', r'''First true branch wins; ELSE avoids unintended NULL; result types must be compatible.''', code: r'''SELECT invoice_id,
       CASE WHEN paid_at IS NULL THEN 'open'
            ELSE 'paid' END AS payment_state
FROM Invoices;'''),
    questionDraft(r'''How can a query find the second-highest distinct salary?''', r'''Rank distinct salary values in descending order and select the value whose dense rank is two. This avoids assumptions about gaps between salary amounts and avoids returning multiple employees when the question asks for the second distinct value.''', r'''For salaries 90000, 90000, and 80000, the second distinct salary is 80000.''', r'''This pattern appears in ranking and threshold questions, with NULL handling considered explicitly.''', r'''Define distinctness; use DENSE_RANK; order descending; handle fewer than two values.''', code: r'''WITH SalaryRanks AS (
  SELECT salary,
         DENSE_RANK() OVER (ORDER BY salary DESC) AS position
  FROM (SELECT DISTINCT salary FROM Employees) AS s
)
SELECT salary
FROM SalaryRanks
WHERE position = 2;'''),
    questionDraft(r'''What is the difference between a view and a materialized view?''', r'''A conventional view stores a query definition and computes its result when queried, while a materialized view stores a result snapshot that must be refreshed to reflect source changes. Refresh support, freshness guarantees, and incremental maintenance vary by database.''', r'''A complex sales summary may be materialized and refreshed nightly for a dashboard.''', r'''Views simplify interfaces; materialized views trade freshness and storage for query speed.''', r'''View stores definition; materialized view stores results; refresh and staleness are product-specific.'''),
    questionDraft(r'''How do indexes improve database queries?''', r'''An index is an auxiliary structure that can help locate rows or satisfy ordering without scanning the entire table. It consumes storage and adds write-maintenance cost, and the optimizer may still choose a table scan when that is cheaper.''', r'''An index on customer_id can accelerate selective lookups and joins by that key.''', r'''Indexes improve measured access paths, not every query or every workload.''', r'''Read benefit versus write/storage cost; selectivity matters; inspect actual execution plans.''', code: r'''CREATE INDEX idx_orders_customer
ON Orders(customer_id);'''),
    questionDraft(r'''What is a composite index and why does column order matter?''', r'''A composite index contains multiple key columns in a defined order, which determines the key prefixes and sort order it can efficiently support. An index on (a, b) commonly supports predicates beginning with a more directly than predicates on b alone, subject to database capabilities.''', r'''An index on (customer_id, order_date) can support customer-specific date ranges and ordered retrieval.''', r'''Index column order should reflect frequent filters, joins, and ordering patterns.''', r'''Leading columns matter; equality/range order affects use; check the engine's optimizer and plan.''', code: r'''CREATE INDEX idx_orders_customer_date
ON Orders(customer_id, order_date);'''),
    questionDraft(r'''What is a database transaction?''', r'''A transaction groups operations into a unit whose effects are committed together or rolled back on failure, subject to the database's transactional guarantees. Transaction boundaries should be kept purposeful to avoid holding locks and resources longer than needed.''', r'''Transfer funds by debiting one account and crediting another in a single transaction.''', r'''Transactions protect multi-step business changes from partial application.''', r'''BEGIN/COMMIT/ROLLBACK; atomic unit; failure handling and connection state matter.''', code: r'''BEGIN;
UPDATE Accounts SET balance = balance - 25 WHERE account_id = 1;
UPDATE Accounts SET balance = balance + 25 WHERE account_id = 2;
COMMIT;'''),
    questionDraft(r'''What does ACID stand for?''', r'''ACID describes transaction properties: atomicity, consistency, isolation, and durability. The exact guarantees depend on the database engine, configuration, and isolation level, so the label alone does not specify every concurrency behavior.''', r'''A committed payment should survive a server restart, while a failed multi-row update should not leave only half its changes.''', r'''ACID reasoning helps evaluate correctness of transactional workflows and storage systems.''', r'''Atomicity all-or-nothing; consistency preserves constraints; isolation controls concurrency; durability persists commit.'''),
    questionDraft(r'''What is SQL injection and how do parameterized queries prevent it?''', r'''SQL injection occurs when untrusted input is interpreted as part of SQL syntax rather than as data. Parameterized queries keep values separate from the statement text, so user input cannot alter its structure; identifiers such as table names require safe allow-listing or database-specific identifier quoting.''', r'''A login lookup binds the submitted username as a parameter instead of concatenating it into SQL.''', r'''Parameterized statements are a foundational defense for application database access.''', r'''Bind values; never concatenate untrusted input; allow-list dynamic identifiers; least-privilege accounts.''', code: r'''SELECT user_id
FROM Users
WHERE username = ?; -- bind the username value separately'''),
    questionDraft(r'''What is the difference between DELETE and TRUNCATE?''', r'''DELETE is a DML statement that removes selected rows and can use a WHERE predicate; TRUNCATE is generally a more specialized operation that removes all rows with engine-specific logging, locking, identity, and transaction behavior. Exact semantics vary across database products, so operational requirements must be checked for the target engine.''', r'''Delete expired sessions selectively with DELETE; use TRUNCATE only when clearing an entire staging table is intended.''', r'''Choosing correctly affects safety, performance, triggers, logging, and rollback behavior.''', r'''DELETE may filter rows; TRUNCATE typically clears whole table; identity and transactional behavior differ by dialect.''', code: r'''DELETE FROM Sessions
WHERE expires_at < CURRENT_TIMESTAMP;'''),
    questionDraft(r'''How do UPDATE and DELETE statements avoid accidental full-table changes?''', r'''UPDATE changes column values for rows matching its WHERE condition, and DELETE removes rows matching its condition; omitting WHERE affects every row. A transaction and a preview SELECT can help verify the intended target set before applying a destructive change.''', r'''Preview customer IDs with an obsolete flag before updating those matching records.''', r'''Careful targeting limits unintended damage in maintenance operations.''', r'''Validate predicate; use transaction where supported; check affected row count; backups for critical changes.''', code: r'''UPDATE Customers
SET status = 'inactive'
WHERE last_seen < DATE '2024-01-01';'''),
    questionDraft(r'''What is normalization in relational database design?''', r'''Normalization structures relations to reduce redundant facts and avoid insertion, update, and deletion anomalies. The appropriate design depends on dependencies and workload; denormalization can be a deliberate performance trade-off when consistency is managed.''', r'''Store a customer's address once in Customers rather than repeating it on every order row.''', r'''Normalization makes updates consistent and clarifies ownership of facts.''', r'''Reduce redundancy; identify functional dependencies; balance read performance with integrity.'''),
  ],
  advanced: [
    questionDraft(r'''How does transaction isolation affect concurrent reads and writes?''', r'''Isolation levels determine which concurrent changes a transaction can observe and which anomalies are prevented, such as dirty reads, non-repeatable reads, or phantoms. Implementations differ, and serializable isolation can use locking or conflict detection with possible retries, so application behavior must match the specific engine.''', r'''Two transactions decrementing the last inventory unit must not both conclude that stock remains available.''', r'''Isolation design protects invariants under concurrent load while balancing throughput and retries.''', r'''Know anomaly guarantees; engine implementations vary; handle deadlocks/serialization failures with bounded retry.'''),
    questionDraft(r'''What is a phantom read?''', r'''A phantom occurs when a transaction reruns a predicate-based query and sees a different set of rows because another transaction inserted, deleted, or modified rows matching that predicate. Serializable isolation prevents such anomalies according to its contract, though the implementation may differ.''', r'''A transaction counts unpaid invoices below a threshold twice and sees a new matching invoice appear between reads.''', r'''Phantom awareness matters when decisions depend on a set of rows, not just previously read records.''', r'''Predicate set changes; distinct from changed values in existing rows; isolation implementation matters.'''),
    questionDraft(r'''How can deadlocks arise, and how should an application respond?''', r'''A deadlock occurs when transactions hold resources while each waits for a resource held by another, forming a cycle. The database typically aborts a victim; applications should keep transactions short, acquire resources consistently, and retry eligible transactions with bounded backoff.''', r'''Two transfers update account rows in opposite order and each waits for the other's lock.''', r'''Deadlock-aware design keeps high-concurrency transaction processing resilient.''', r'''Cyclic wait; database selects victim; consistent lock order and safe retry reduce impact.'''),
    questionDraft(r'''What is a covering index?''', r'''A covering index contains all columns needed by a query's predicates and output, allowing the engine to satisfy it from the index without fetching base table rows in some plans. The extra columns increase index size and write cost, and syntax for included columns differs by database.''', r'''A query filtering on status and returning order_id can be covered by an appropriate index over those values.''', r'''Covering indexes can reduce I/O on high-volume read paths after plan-based measurement.''', r'''Query columns covered; may avoid table lookup; larger index costs; implementation syntax varies.'''),
    questionDraft(r'''How do you diagnose a slow SQL query using an execution plan?''', r'''An execution plan describes the operations the optimizer expects or actually performs, such as scans, joins, sorts, and estimates of row counts and costs. Compare estimated with actual cardinalities where available, inspect high-cost or unexpectedly broad operations, and validate changes with representative data and workload.''', r'''A plan showing a large table scan for a selective customer lookup may suggest checking statistics, predicates, or an index.''', r'''Plan analysis guides evidence-based query and schema tuning.''', r'''Use EXPLAIN/actual plan; compare row estimates and actuals; no single operator label proves a problem.'''),
    questionDraft(r'''Why can a function applied to an indexed column prevent an index seek?''', r'''A predicate such as `LOWER(email) = ...` may not match a plain index on email because the engine must evaluate a transformed value for candidate rows. A functional/computed-column index or a sargable predicate aligned with stored normalization may enable an efficient access path.''', r'''Search normalized email addresses using a matching computed index rather than applying LOWER to every row.''', r'''Sargability matters for selective filtering at scale.''', r'''Avoid unnecessary column-side transformations; functional indexes are product-specific; verify with plans.''', code: r'''-- Prefer a range predicate over extracting YEAR from every timestamp.
SELECT event_id
FROM Events
WHERE event_time >= TIMESTAMP '2026-01-01 00:00:00'
  AND event_time <  TIMESTAMP '2027-01-01 00:00:00';'''),
    questionDraft(r'''How does keyset pagination differ from OFFSET pagination?''', r'''OFFSET pagination skips a number of rows after sorting, and large offsets can require the database to process many preceding rows; concurrent changes can also shift page boundaries. Keyset pagination uses the last seen ordering key as a seek boundary, often offering stable and efficient continuation when the order is unique and indexed.''', r'''Continue an order feed with `(created_at, order_id) < (:last_time, :last_id)` for descending order.''', r'''Keyset paging suits large, changing feeds and avoids increasingly expensive skips.''', r'''Unique deterministic sort; cursor encodes last key; semantics differ for random page jumps.''', code: r'''SELECT order_id, created_at
FROM Orders
WHERE (created_at, order_id) < (:last_time, :last_id)
ORDER BY created_at DESC, order_id DESC
FETCH FIRST 25 ROWS ONLY;'''),
    questionDraft(r'''When is a recursive CTE appropriate?''', r'''A recursive CTE evaluates an anchor query and repeatedly evaluates a recursive member using prior results until no further rows are produced or an engine limit is reached. It is well suited to hierarchical or graph-like traversal, but cycles and explosive recursion require explicit safeguards.''', r'''Traverse a manager hierarchy from a selected employee to all descendants.''', r'''Recursive queries avoid hard-coding hierarchy depth in organizational or bill-of-materials reporting.''', r'''Anchor plus recursive member; termination is essential; guard cycles and depth; syntax varies slightly.''', code: r'''WITH RECURSIVE Org AS (
  SELECT employee_id, manager_id, 0 AS depth
  FROM Employees WHERE employee_id = :root_id
  UNION ALL
  SELECT e.employee_id, e.manager_id, o.depth + 1
  FROM Employees AS e
  JOIN Org AS o ON e.manager_id = o.employee_id
)
SELECT employee_id, depth FROM Org;'''),
    questionDraft(r'''How can you make a top-per-group query deterministic?''', r'''Use ROW_NUMBER partitioned by the grouping key and order by the desired ranking value plus a unique tie-breaker, then filter to row number one. Without a total ordering, equal-valued candidates can be selected unpredictably.''', r'''Select the latest support ticket per customer, breaking equal timestamps by the greatest ticket_id.''', r'''Top-per-group logic is common in current-state reports and latest-record selection.''', r'''Partition by group; order with unique tie-breaker; filter ranked result in an outer query or CTE.''', code: r'''WITH Ranked AS (
  SELECT t.*,
         ROW_NUMBER() OVER (
           PARTITION BY customer_id
           ORDER BY updated_at DESC, ticket_id DESC
         ) AS rn
  FROM Tickets AS t
)
SELECT customer_id, ticket_id, updated_at
FROM Ranked
WHERE rn = 1;'''),
    questionDraft(r'''How does table partitioning help manage very large datasets?''', r'''Partitioning divides one logical table into physical or logical subsets according to a partition key, such as a date range. It can enable partition pruning and simplify lifecycle operations, but does not automatically make every query faster and requires a suitable predicate and maintenance strategy.''', r'''Partition an event table by month so a recent-quarter query can avoid scanning older partitions.''', r'''Partitioning supports large time-series tables, data retention, and targeted maintenance.''', r'''Choose key aligned to workloads; pruning depends on predicates; manage partition boundaries and indexes.''', code: r'''-- Illustrative range partitioning; syntax is database-specific.
CREATE TABLE Events (
  event_id BIGINT,
  event_time TIMESTAMP NOT NULL
) PARTITION BY RANGE (event_time);'''),
  ],
);
