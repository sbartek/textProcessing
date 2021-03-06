library("data.table")
library("magrittr")

source("splitText.R")

MIN_GRAMS <- 2

prepare1gram <- function() {
  "../data/gram1final.csv" %>%
    fread %>%
    setnames(c("word1", "count1")) %>%
    .[order(-count1)] %>%
    .[1, .(word1)] %>%
    write.csv("simple1gram.csv", row.names = FALSE, quote=FALSE)
}

prepare2gram <- function() {
  dt2 <-
    "../data/gram2final.csv" %>%
    fread %>%
    setnames(c("word1", "word2", "count2")) %>%
    .[count2 >=  MIN_GRAMS]
  dt1 <-
    "../data/gram1final.csv" %>%
    fread %>%
    setnames(c("word1", "count1")) %>%
    .[count1 >=  MIN_GRAMS]
  merge(dt2, dt1, by="word1") %>%
    .[order(-count2, -count1)] %>%
    .[,.SD[1], by=.(word1)] %>%
    .[, .(word1, word2)] %>%
    write.csv("simple2gram.csv", row.names = FALSE, quote=FALSE)
}

prepare3gram <- function() {
  dt3 <-
    "../data/gram3final.csv" %>%
    fread %>%
    setnames(c("word1", "word2", "word3", "count3")) %>%
    .[count3 >=  MIN_GRAMS]
  dt2 <-
    "../data/gram2final.csv" %>%
    fread %>%
    setnames(c("word1", "word2", "count2")) %>%
    .[count2 >=  MIN_GRAMS]
  dt1 <-
    "../data/gram1final.csv" %>%
    fread %>%
    setnames(c("word1", "count1")) %>%
    .[count1 >=  MIN_GRAMS]
  merge(dt3, dt2, by=c("word1", "word2")) %>%
    merge(dt1, by="word1") %>%
    .[order(-count3, -count2, -count1)] %>%
    .[,.SD[1], by=.(word1, word2)] %>%
    .[, .(word1, word2, word3)] %>%
    write.csv("simple3gram.csv", row.names = FALSE, quote=FALSE)
}

prepare4gram <- function() {
  dt4 <-
    "../data/gram4final.csv" %>%
    fread %>%
    setnames(c("word1", "word2", "word3", "word4", "count4")) %>%
    .[count4 >=  MIN_GRAMS]

  dt3 <-
    "../data/gram3final.csv" %>%
    fread %>%
    setnames(c("word1", "word2", "word3", "count3")) %>%
    .[count3 >=  MIN_GRAMS]
  dt2 <-
    "../data/gram2final.csv" %>%
    fread %>%
    setnames(c("word1", "word2", "count2")) %>%
    .[count2 >=  MIN_GRAMS]
  dt1 <-
    "../data/gram1final.csv" %>%
    fread %>%
    setnames(c("word1", "count1")) %>%
    .[count1 >=  MIN_GRAMS]
  merge(dt4, dt3, by=c("word1", "word2", "word3")) %>%
    merge(dt2, by=c("word1", "word2")) %>%
    merge(dt1, by="word1") %>%
    .[order(-count4, -count3, -count2, -count1)] %>%
    .[,.SD[1], by=.(word1, word2)] %>%
    .[, .(word1, word2, word3, word4)] %>%
    write.csv("simple4gram.csv", row.names = FALSE, quote=FALSE)
}

simplePredictor1 <- function() {
  dt1 <- fread("simple1gram.csv", header=TRUE)
  f <- function(splitted) {
    dt1[1, word1]
  }
  return(f)
}

simplePredictor2 <- function(f1) {
  dt2 <- fread("simple2gram.csv", header=TRUE)
  f <- function(splitted) {
    n <- length(splitted)
    pred <- dt2[word1 == splitted[n], word2]
    if (length(pred) != 0) {
      pred
    } else {
      f1(splitted)
    }
  }
  return(f)
}

simplePredictor3 <- function(f2) {
  dt3 <- fread("simple3gram.csv", header=TRUE)
  f <- function(splitted) {
    n <- length(splitted)
    pred <- dt3[word1 == splitted[n-1] & word2 == splitted[n], word3]
    if (length(pred) != 0) {
      pred
    } else {
      f2(splitted)
    }
  }
  return(f)
}

simplePredictor4 <- function(f3) {
  dt4 <- fread("simple4gram.csv", header=TRUE)
  f <- function(splitted) {
    n <- length(splitted)
    pred <- dt4[word1 == splitted[n-2] & word2 == splitted[n-1] & word3 == splitted[n], word4]
    if (length(pred) != 0) {
      pred
    } else {
      f3(splitted)
    }
  }
  return(f)
}

simplePredictor <- function() {
  f1 <- simplePredictor1()
  f2 <- simplePredictor2(f1)
  f3 <- simplePredictor3(f2)
  f4 <- simplePredictor4(f3)
  
  sp <- function(text) {
    splitted <- splitText(text)
    n <- length(splitted)
    if (n == 0) {
      f1(splitted)
    } else {
      if (n == 1) {
        f2(splitted)
      } else {
        if (n == 2) {
          f3(splitted)
        } else {
          f4(splitted)
        }
      }
    }
  }
  return(sp)
}
