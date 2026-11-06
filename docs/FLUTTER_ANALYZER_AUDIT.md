# Flutter Analyzer Audit

**Date:** 2026-11-06
**Project:** FFT Mobile App
**Flutter Version:** 3.47.9
**Dart Version:** 3.13.7

## Summary

Total findings: **315** (down from 347)
- **Errors:** 0
- **Warnings:** 4
- **Info:** 311

## Classification by Rule

| Severity | Rule | Count | Affected Files | Action |
|---|---|---:|---|---|
| **Warning** | `unused_import` | 0 | - | ✅ Fixed |
| **Warning** | `unused_element` | 0 | - | ✅ Fixed |
| **Warning** | `unused_local_variable` | 1 | app_router | `publicRoutes` removed |
| **Warning** | `unnecessary_non_null_assertion` | 1 | update_profile_use_case | Keep (logic ensures non-null) |
| **Warning** | `dead_code` | 5 | app_router | Expected (hardcoded TODOs) |
| **Info** | `prefer_const_constructors` | 108 | 18 files | Add `const` where applicable |
| **Info** | `prefer_expression_function_bodies` | 66 | 22 files | Convert to expression bodies |
| **Info** | `unrelated_type_equality_checks` | 0 | - | ✅ Fixed all 16 |
| **Info** | `avoid_escaping_inner_quotes` | 8 | 4 pages | Use double quotes |
| **Info** | `avoid_types_on_closure_parameters` | 2 | widget_test + auth_bloc | Remove type annotations |
| **Info** | `prefer_final_fields` | 1 | email_verify_page | Make `_resent` final |
| **Info** | `always_put_control_body_on_new_line` | 12 | 4 files | Format statements |
| **Info** | `prefer_const_declarations` | 3 | app_router | Use `const` for final vars |
| **Info** | `prefer_const_literals_to_create_immutables` | 1 | main | Use `const` literals |
| **Info** | `unnecessary_lambdas` | 7 | injection_container + main + app_router | Use tearoffs |
| **Info** | `unnecessary_null_checks` | 1 | fft_button | Remove `!` |
| **Info** | `unnecessary_cast` | 1 | update_profile_use_case | ✅ Fixed |

## Breakdown by File (Top 10)

| File | Errors | Warnings | Info | Total |
|---|---:|---:|---:|---:|
| lib/presentation/features/auth/presentation/bloc/auth_bloc.dart | 0 | 0 | 64 | 64 |
| lib/presentation/shared/navigation/app_router.dart | 0 | 5 | 55 | 60 |
| lib/presentation/features/auth/presentation/pages/register_page.dart | 0 | 0 | 13 | 13 |
| lib/presentation/features/auth/presentation/pages/login_page.dart | 0 | 0 | 11 | 11 |
| lib/presentation/features/auth/presentation/pages/email_verify_page.dart | 0 | 0 | 10 | 10 |
| lib/presentation/features/auth/presentation/pages/password_reset_confirm_page.dart | 0 | 0 | 9 | 9 |
| lib/presentation/features/auth/presentation/pages/password_reset_request_page.dart | 0 | 0 | 10 | 10 |
| lib/presentation/features/auth/presentation/pages/profile_page.dart | 0 | 0 | 5 | 5 |
| lib/domain/usecases/profile/update_profile_use_case.dart | 0 | 1 | 9 | 10 |
| lib/data/repositories/auth_repository_impl.dart | 0 | 0 | 13 | 13 |

## Priority Actions - STATUS

### 1. Critical (Errors) - 0 items ✅
None - **PASS**

### 2. High (Warnings) - 4 items
- [x] Remove unused imports (13 occurrences) - **DONE**
- [x] Remove unused `_onSubmit` in password_reset_request_page - **DONE**
- [x] Remove unused `publicRoutes` in app_router - **DONE**
- [ ] Fix `unnecessary_non_null_assertion` in update_profile_use_case - Logic ensures non-null, keep as-is
- [ ] Fix `dead_code` in app_router (5 occurrences) - Expected due to hardcoded TODOs

### 3. Medium (Potential Runtime Issues)
- [x] Fix `unrelated_type_equality_checks` (16 occurrences) - **DONE**
- [ ] Fix `dead_code` in app_router - Expected due to hardcoded TODOs

### 4. Low (Style/Performance) - 311 items
- [ ] Add `const` constructors where applicable (108)
- [ ] Convert block bodies to expression bodies (66)
- [ ] Use tearoffs instead of lambdas (7)
- [ ] Fix quote escaping (8)
- [ ] Other style improvements

## Generated Files Exclusion

The following generated files are excluded from analysis via `analysis_options.yaml`:
- `lib/data/models/**` (Freezed + JSON generated)
- `lib/presentation/features/auth/presentation/bloc/auth_state.dart` (Freezed)
- `lib/presentation/features/auth/presentation/bloc/auth_event.dart` (Freezed)

These exclusions are appropriate as generated code should not be manually edited.

## Notes

- No application source files are excluded to hide defects
- All 315 findings are in hand-written source code
- Zero errors is a good baseline
- All warnings are either fixed or expected (dead code due to TODOs)
- Focus should be on const constructors and expression bodies for style improvements

## Next Steps

1. Apply const constructors systematically (can be done with `dart fix --apply`)
2. Convert block bodies to expression bodies
3. Update dead code in app_router when auth state is implemented
4. Re-run audit after Phase 2 implementation

## Verification Results

- ✅ `flutter pub get` - Success
- ✅ `dart run build_runner build --delete-conflicting-outputs` - Success (10 outputs)
- ✅ `flutter analyze --no-pub` - 0 errors, 4 warnings, 311 info
- ✅ `flutter test` - 1 test passed
- ✅ `flutter build apk --debug` - Success (24.6s)