require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/pdftohtmlr')

class PdfFileTest < Test::Unit::TestCase
  include PDFToHTMLR

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__)) + "/"
  TEST_PDF_PATH = CURRENT_DIR + "test.pdf"
  TEST_PWD_PDF_PATH = CURRENT_DIR + "test_pw.pdf"
  TEST_BAD_PATH = "blah.pdf"

  def test_pdffile_new
    file = PdfFile.new(TEST_PDF_PATH, ".", nil, nil)
    assert file
  end

  def test_bad_pdffile_new
    assert_raise PDFToHTMLRError do
      file = PdfFile.new(TEST_BAD_PATH, ".", nil, nil)
    end
  end

  def test_string_from_pdffile
    file = PdfFile.new(TEST_PDF_PATH, ".", nil, nil)
    assert_equal "String", file.convert().class.to_s
    assert_equal `pdftohtml -stdout #{TEST_PDF_PATH}`, file.convert() 
  end 

  def test_invalid_pwd_pdffile
    assert_raise PDFToHTMLRError do
      file = PdfFile.new(TEST_PWD_PDF_PATH, ".", "blah", nil)
      file.convert
    end
  end

  def test_valid_pwd_pdffile
    file = PdfFile.new(TEST_PWD_PDF_PATH, ".", "user", nil)
    assert_equal "String", file.convert().class.to_s
    assert_equal `pdftohtml -stdout -upw user #{TEST_PWD_PDF_PATH}`,
    file.convert()
  end

end