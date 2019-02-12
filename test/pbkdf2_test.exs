defmodule Pbkdf2Test do
  use ExUnit.Case, async: false

  def hash_check_password(password, wrong1, wrong2, wrong3) do
    hash = Pbkdf2.hash_pwd_salt(password)
    assert Pbkdf2.verify_pass(password, hash) == true
    assert Pbkdf2.verify_pass(wrong1, hash) == false
    assert Pbkdf2.verify_pass(wrong2, hash) == false
    assert Pbkdf2.verify_pass(wrong3, hash) == false
  end

  test "pbkdf2 dummy check" do
    assert Pbkdf2.no_user_verify() == false
  end

  test "hashing and checking passwords" do
    hash_check_password("password", "passwor", "passwords", "pasword")
    hash_check_password("hard2guess", "ha rd2guess", "had2guess", "hardtoguess")
  end

  test "hashing and checking passwords with characters from the extended ascii set" do
    hash_check_password("aáåäeéêëoôö", "aáåäeéêëoö", "aáåeéêëoôö", "aáå äeéêëoôö")
    hash_check_password("aáåä eéêëoôö", "aáåä eéê ëoö", "a áåeé êëoôö", "aáå äeéêëoôö")
  end

  test "hashing and checking passwords with non-ascii characters" do
    hash_check_password(
      "Сколько лет, сколько зим",
      "Сколько лет,сколько зим",
      "Сколько лет сколько зим",
      "Сколько лет, сколько"
    )

    hash_check_password("สวัสดีครับ", "สวัดีครับ", "สวัสสดีครับ", "วัสดีครับ")
  end

  test "hashing and checking passwords with mixed characters" do
    hash_check_password("Я❤três☕ où☔", "Я❤tres☕ où☔", "Я❤três☕où☔", "Я❤três où☔")
  end

  test "gen_salt length of salt" do
    assert byte_size(Pbkdf2.gen_salt()) == 16
    assert byte_size(Pbkdf2.gen_salt(32)) == 32
    assert byte_size(Pbkdf2.gen_salt(64)) == 64
  end

  test "hashes with different lengths are correctly verified" do
    hash = Pbkdf2.hash_pwd_salt("password", length: 128)
    assert Pbkdf2.verify_pass("password", hash) == true
    django_hash = Pbkdf2.hash_pwd_salt("password", length: 128, format: :django)
    assert Pbkdf2.verify_pass("password", django_hash) == true
  end
end
