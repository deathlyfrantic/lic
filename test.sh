CURRENT_DIR="`pwd`"
LIC="$CURRENT_DIR/lic"

oneTimeSetUp() {
    cd "$SHUNIT_TMPDIR"
    git init -q
    git config user.name "Foobar McGee"
    cd "$CURRENT_DIR"
    echo "TEST {{author}} {{year}} END" > licenses/test_license
    echo "TEST2 {{author}} {{year}} END" > licenses/test_license2
}

oneTimeTearDown() {
    cd "$CURRENT_DIR"
    rm licenses/test_license
    rm licenses/test_license2
}

setUp() {
    cd "$SHUNIT_TMPDIR"
}

tearDown() {
    [ -r LICENSE ] && rm LICENSE
    cd "$CURRENT_DIR"
}

template() {
    year=`date +"%Y"`
    cat "$CURRENT_DIR/licenses/$1" |
        sed "s/{{year}}/$year/" |
        sed "s/{{author}}/Zandr Martin/"
}

lic() {
    $LIC "$@" > /dev/null
}

test_show_usage_when_no_arguments() {
    assertTrue "Does not show usage." "[ -n \"`$LIC | grep Usage`\" ]"
}

test_specifying_license_dir() {
    mkdir foo
    touch foo/{a,b,c}
    output="`LICENSE_DIR=foo $LIC -h`"
    assertTrue \
        "Does not show 'a, b, c' as available licenses." \
        "[ -n \"`LICENSE_DIR=foo $LIC | grep 'Available licenses: a, b, c'`\" ]"
    rm -rf foo
}

test_add_license_when_none_exists() {
    lic test_license
    assertTrue "LICENSE does not exist." "[ -f LICENSE ]"
    assertEquals "TEST Foobar McGee `date +"%Y"` END" "`cat LICENSE`"
}

test_abort_when_license_exists() {
    lic test_license
    assertTrue "LICENSE does not exist." "[ -f LICENSE ]"
    assertFalse "Did not confirm overwrite." "[ `echo n | lic test_license` ]"
}

test_overwrite_when_license_exists() {
    lic test_license
    assertTrue "LICENSE does not exist." "[ -f LICENSE ]"
    assertEquals "TEST Foobar McGee `date +"%Y"` END" "`cat LICENSE`"

    echo y | lic test_license2
    assertTrue "LICENSE does not exist." "[ -f LICENSE ]"
    assertNotEquals "TEST Foobar McGee `date +"%Y"` END" "`cat LICENSE`"
    assertEquals "TEST2 Foobar McGee `date +"%Y"` END" "`cat LICENSE`"
}

test_failure_when_author_is_unknown() {
    git config user.name ""
    assertFalse "Did not fail without author." "[ `lic test_license` ]"
    git config user.name "Foobar McGee"
}

test_author_specification() {
    lic -a "John Doe" test_license
    assertTrue "LICENSE does not exist." "[ -f LICENSE ]"
    assertEquals "TEST John Doe `date +"%Y"` END" "`cat LICENSE`"
}

test_year_specification() {
    lic -y 1999 test_license
    assertTrue "LICENSE does not exist." "[ -f LICENSE ]"
    assertEquals "TEST Foobar McGee 1999 END" "`cat LICENSE`"
}

test_license_filename_specification() {
    lic -l OUTPUT_FILE test_license
    assertTrue "OUTPUT_FILE does not exist." "[ -f OUTPUT_FILE ]"
    assertEquals "TEST Foobar McGee `date +"%Y"` END" "`cat OUTPUT_FILE`"
    assertFalse "LICENSE does exist." "[ -f LICENSE ]"
}

test_gitcommit() {
    assertTrue \
        "There is already a commit." \
        "[ -z `git log -n1 --pretty='tformat:%s' 2> /dev/null` ]"
    lic -g test_license
    assertEquals \
        "Add test_license license." \
        "`git log -n1 --pretty='tformat:%s' 2> /dev/null`"
}

test_gitcommit_fails_when_staged_changes_exist() {
    touch foo
    git add foo
    assertTrue "Not a git repo" "[ -d .git ]"
    assertFalse "Did not fail to commit." "[ `lic -g test_license` ]"
    assertTrue "Did not write LICENSE." "[ -f LICENSE ]"
}

test_gitcommit_fails_when_not_git_repo() {
    rm -rf .git
    assertTrue "Still a git repo." '[ -z "`git status 2> /dev/null`" ]'
    assertFalse "Did not fail to commit." "[ `lic -g test_license` ]"
    assertTrue "Did not write LICENSE." "[ -f LICENSE ]"

    # reset git repo for other tests
    git init -q
    git config user.name "Foobar McGee"
}
