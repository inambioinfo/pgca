library(pgca)
context("Saving and applying the dictionary")

test_that("Saving a dictionary", {
    dict <- pgcaDict(
        system.file("extdata", package="pgca"),
        col.mapping=c(gene.symbol="Gene_Symbol")
    )

    ## Test for expected errors
    expect_error({
        saveDict(dict)
    })
    expect_error({
        saveDict("no dictionary!")
    })
    expect_error({
        saveDict(list(dictionary = data.frame()))
    })

    ## Test for expected file contents
    out <- tempfile()
    saveDict(dict, file = out)

    saved <- read.table(out, stringsAsFactors = FALSE, header = TRUE,
                        colClasses = "character")

    expect_equal_to_reference(saved, "testdata/dict-file-output.rds")
})


test_that("Translating files", {
    dict <- pgcaDict(
        system.file("extdata", package="pgca"),
        col.mapping=c(gene.symbol="Gene_Symbol")
    )

    ## Test for expected errors
    expect_error({
        applyDict(dict="asdf")
    })
    expect_error({
        applyDict(
            system.file("extdata", package="pgca")
        )
    })

    ##
    ## Test for correctly returned data frames
    ##
    translated.df <- applyDict(
        system.file("extdata", package="pgca"),
        dict=dict
    )

    expect_false(anyNA(match(
        names(translated.df),
        dir(system.file("extdata", package="pgca"), full.names = TRUE)
    )))

    expect_equal_to_reference(translated.df, "testdata/translated-df.rds",
                              check.attributes = FALSE)

    ##
    ## Test for correctly written files
    ##
    out.dir <- tempdir()

    # Using the filename
    applyDict(
        system.file("extdata", "BET1947_v339.txt", package="pgca"),
        dict=dict,
        out.dir=out.dir
    )

    expect_identical(
        dir(out.dir, pattern="BET1947_v339.txt"),
        "BET1947_v339.txt"
    )

    # Using the variable name of the argument
    my.df <- BET1947_v339
    applyDict(
        my.df,
        dict=dict,
        out.dir=out.dir
    )

    expect_identical(
        dir(out.dir, pattern="my.df"),
        "my.df.txt"
    )

    # Using the name of the argument
    applyDict(
        myfile=BET1947_v339,
        dict=dict,
        out.dir=out.dir
    )

    expect_identical(
        dir(out.dir, pattern="myfile"),
        "myfile.txt"
    )

    # Adding a prefix
    applyDict(
        system.file("extdata", "BET1947_v339.txt", package="pgca"),
        dict=dict,
        out.dir=out.dir,
        out.prefix="translated-"
    )

    expect_identical(
        dir(out.dir, pattern="translated-BET1947_v339"),
        "translated-BET1947_v339.txt"
    )

    # Adding a suffix
    applyDict(
        system.file("extdata", "BET1947_v339.txt", package="pgca"),
        dict=dict,
        out.dir=out.dir,
        out.suffix="-translated"
    )

    expect_identical(
        dir(out.dir, pattern="BET1947_v339-translated"),
        "BET1947_v339-translated.txt"
    )

    ## Test that we do not override existing files
    expect_error({
        applyDict(
            myfile=BET1947_v339,
            dict=dict,
            out.dir=out.dir
        )
    })
})

