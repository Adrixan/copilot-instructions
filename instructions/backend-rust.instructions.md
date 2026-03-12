---
applyTo: 
  - "**/*.rs"
  - "**/Cargo.toml"
  - "**/Cargo.lock"
---
<!-- markdownlint-disable MD013 MD022 MD031 MD032 -->
<rust_standards>

## Rust

- **Rust stable** with Cargo — pin toolchain via `rust-toolchain.toml`
- **Ownership [MUST]:** Work with the borrow checker, not against it. When the compiler rejects code, redesign the data flow before reaching for `clone()` or `Rc<RefCell<>>`. `clone()` on large data requires inline comment justifying it. Fighting lifetimes = redesign needed.
- **Standard library first:** Prefer `std` types and traits over third-party when sufficient.

**Error Handling [MUST]:**

- Library crates: `thiserror` for typed, domain-specific error enums.
- Binary crates: `anyhow` for ergonomic error propagation.
- `unwrap()` / `expect()` forbidden in production paths. OK in tests and `main` startup.
- Every other use requires `// SAFETY:` or `// INVARIANT:` comment explaining why it cannot fail.
- Use `?` operator for propagation. Map errors at module boundaries.

**Async Runtime [MUST]:**

- One runtime per project. Tokio is default unless project has a reason otherwise.
- `block_on` inside async context is forbidden (deadlocks).
- `tokio::spawn` tasks must be: awaited, stored with `JoinHandle`/abort handle, or documented as fire-and-forget with `// FIRE-AND-FORGET:` comment.
- Prefer `tokio::select!` for concurrent operations. Cancel-safety must be considered.

**Unsafe [MUST]:**

- Every `unsafe` block has `// SAFETY:` comment explaining why this is sound and what invariants the caller must maintain.
- `unsafe` blocks as small as possible — isolate the unsafe operation, do validation outside.
- New `unsafe` code requires stopping to ask first before writing.
- Prefer safe abstractions: `std::mem::take`, `std::mem::replace` over raw pointer manipulation.

**Package Structure [MUST]:**

- Organize by domain, not by type (no `models/`, `controllers/` directories).
- Modules are `pub(crate)` by default. Only expose what's part of the public API.
- Use `lib.rs` for library logic, `main.rs` as thin entry point that calls into lib.
- Workspace (`Cargo.toml` workspace) for multi-crate projects.

**Type Safety:**

- Use newtypes for domain concepts: `struct UserId(i64)` — not bare primitives.
- Leverage `From`/`Into` traits for conversions. Avoid `.as()` casts on numeric types without bounds checking.
- Prefer enums over boolean flags for state.
- Use `#[must_use]` on functions where ignoring the return value is likely a bug.

**Testing [SHOULD]:**

- Unit tests in `#[cfg(test)]` module at bottom of each file.
- Integration tests in `tests/` directory, using public API only.
- Property-based testing (`proptest` / `quickcheck`) for functions with complex input spaces.
- Use `#[should_panic]` sparingly — prefer `Result`-returning tests.

**Dependencies:**

- Audit new dependencies: check maintenance status, download count, `cargo audit` results.
- Prefer widely-adopted crates: `serde` (serialization), `tokio` (async), `tracing` (instrumentation), `clap` (CLI).
- Pin major versions in `Cargo.toml`. Use `cargo deny` for license and advisory checks.

**Performance:**

- Profile before optimizing: `cargo flamegraph`, `criterion` for benchmarks.
- Prefer iterators over indexed loops — the compiler optimizes them better.
- Use `Cow<'_, str>` when ownership is conditionally needed.
- Avoid allocations in hot paths: reuse buffers, prefer `&str` over `String` in read-only contexts.

**Linting:**

- `cargo clippy -- -D warnings` in CI — treat all warnings as errors.
- `cargo fmt --check` enforced in CI.
- Enable `#![deny(clippy::unwrap_used)]` in library crates.

**Pitfalls:**

1. ❌ Fighting borrow checker with `clone()` everywhere → ✅ Redesign ownership; use references, slices, or `Cow`.
2. ❌ `unwrap()` in production code → ✅ Use `?`, `unwrap_or_default()`, or `match` with proper error handling.
3. ❌ Mixing async runtimes (tokio + async-std) → ✅ One runtime per project, chosen at the start.
4. ❌ Large `unsafe` blocks → ✅ Minimize scope, document invariants with `// SAFETY:` comments.
5. ❌ `String` / `Vec` cloning in hot paths → ✅ Use `&str`, `&[T]`, or `Cow` where ownership isn't needed.
6. ❌ Ignoring `must_use` warnings → ✅ Handle or explicitly discard with `let _ =`.
</rust_standards>
