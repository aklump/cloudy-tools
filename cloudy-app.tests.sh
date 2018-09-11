#!/usr/bin/env bash

function testGetConfigForStringReturnsAsExpected() {
    assert_equals "Adam ate apples at Andrew's abode." "$(get_config "unittests.string")"
    assert_equals "Default value." "$(get_config "my.bogus.config.key" "Default value.")"
}

function testAnotherThing () {
    assert_equals "aaron" "aaron"
}
