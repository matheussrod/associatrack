
# Functions ---------------------------------------------------------------

encrypt <- function(x, key, nonce) {
  if (!is.raw(x)) {
    stop('`x` must be raw')
  }
  encrypt <- sodium::data_encrypt(x, key, nonce)
  attr(encrypt, 'nonce') <- NULL
  return(encrypt)
}

decrypt <- function(x, key, nonce) {
  if (!is.raw(x)) {
    stop('`x` must be raw')
  }
  decrypt_raw <- sodium::data_decrypt(x, key, nonce)
  decrypt <- rawToChar(decrypt_raw)
  return(decrypt)
}

create_key <- function(x = NULL) {
  if (is.null(x)) {
    secret <- gargle:::secret_pw_gen()
  }
  else {
    secret <- x
  }
  secret_raw <- charToRaw(secret)
  key <- sodium::hash(secret_raw)
  return(key)
}

create_nonce <- gargle:::secret_nonce
