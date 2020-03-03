# Change log

## 0.6.1 (2020-03-02)

- Fix Ruby 2.7 warnings. ([@palkan][])

## 0.6.0 (2019-08-19)

- **Ruby 2.4+** is required.

- Fix Rails 6 compatibility. ([@palkan][])

## 0.5.0 (2019-02-24)

- Make compatible with Rails 6. ([@palkan][])

  That allows using RSpec part of the gem with Rails 6
  (since Action Cable testing will included only in the upcoming RSpec 4).

- Backport Rails 6.0 API changes. ([@palkan][], [@sponomarev][])

  Some APIs have been deprecated (to be removed in 1.0).

## 0.4.0 (2019-01-10)

- Add stream assert methods and matchers. ([@sponomarev][])

  See https://github.com/palkan/action-cable-testing/pull/42

- Add session support for connection. ([@sponomarev][])

  See https://github.com/palkan/action-cable-testing/pull/35

## 0.3.0

- Add connection unit-testing utilities. ([@palkan][])

  See https://github.com/palkan/action-cable-testing/pull/6

## 0.2.0

- Update minitest's `assert_broadcast_on` and `assert_broadcasts` matchers to support a record as an argument. ([@thesmartnik][])

See https://github.com/palkan/action-cable-testing/issues/11

- Update `have_broadcasted_to` matcher to support a record as an argument. ([@thesmartnik][])

See https://github.com/palkan/action-cable-testing/issues/9

## 0.1.2 (2017-11-14)

- Add RSpec shared contexts to switch between adapters. ([@palkan][])

See https://github.com/palkan/action-cable-testing/issues/4.

## 0.1.1

- Support Rails 5.0.0.1. ([@palkan][])

## 0.1.0

- Initial version. ([@palkan][])

[@palkan]: https://github.com/palkan
[@thesmartnik]: https://github.com/thesmartnik
[@sponomarev]: https://github.com/sponomarev
