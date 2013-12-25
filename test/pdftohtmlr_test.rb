require 'test/unit'
require File.join(File.dirname(__FILE__), '../lib/pdftohtmlr')

class PdfFileTest < Test::Unit::TestCase
  include PDFToHTMLR

  CURRENT_DIR = File.dirname(File.expand_path(__FILE__)) + "/"
  TEST_PDF_PATH = CURRENT_DIR + "test.pdf"
  TEST_PWD_PDF_PATH = CURRENT_DIR + "test_pw.pdf"
  TEST_BAD_PATH = "blah.pdf"
  TEST_NON_PDF = CURRENT_DIR + "pdftohtmlr_test.rb"
  TEST_URL_PDF =
   "https://s3.amazonaws.com/pdf2htmlr/test.pdf"
  TEST_URL_NON_PDF =
   "https://s3.amazonaws.com/pdf2htmlr/pdftohtmlr_test.rb"
  def test_pdffile_new
    file = PdfFilePath.new(TEST_PDF_PATH, ".", nil, nil)
    assert file
  end
  
  def test_invalid_pdffile
    e = assert_raise PDFToHTMLRError do 
      file = PdfFilePath.new(TEST_NON_PDF, ".", nil, nil)
      file.convert
    end
    assert_equal "Error: May not be a PDF file (continuing anyway)", e.to_s
  end

  def test_bad_pdffile_new
    e = assert_raise PDFToHTMLRError do
      file = PdfFilePath.new(TEST_BAD_PATH, ".", nil, nil)
    end
    assert_equal "invalid file path", e.to_s
  end

  def test_string_from_pdffile
    file = PdfFilePath.new(TEST_PDF_PATH, ".", nil, nil)
    assert_equal "String", file.convert().class.to_s
    assert_equal `pdftohtml -stdout "#{TEST_PDF_PATH}"`, file.convert() 
  end 

  def test_invalid_pwd_pdffile
    e = assert_raise PDFToHTMLRError do
      file = PdfFilePath.new(TEST_PWD_PDF_PATH, ".", "blah", nil)
      file.convert
    end
    assert_equal "Error: Incorrect password", e.to_s
  end

  def test_valid_pwd_pdffile
    file = PdfFilePath.new(TEST_PWD_PDF_PATH, ".", "user", nil)
    assert_equal "String", file.convert().class.to_s
    assert_equal `pdftohtml -stdout -upw user "#{TEST_PWD_PDF_PATH}"`,
    file.convert()
  end
  
  def test_return_document
    file = PdfFilePath.new(TEST_PDF_PATH, ".", nil, nil)
    assert_equal "Nokogiri::HTML::Document",
     file.convert_to_document().class.to_s
    assert_equal Nokogiri::HTML.parse(
        `pdftohtml -stdout "#{TEST_PDF_PATH}"`
      ).css('body').first.to_s,
       file.convert_to_document().css('body').first.to_s
  end
  
  def test_return_xml
    file = PdfFilePath.new(TEST_PDF_PATH, ".", nil, nil)
    assert_equal "String", file.convert_to_xml().class.to_s
  end
  
  def test_return_xml_document
    file = PdfFilePath.new(TEST_PDF_PATH, ".", nil, nil)
    assert_equal "Nokogiri::XML::Document",
     file.convert_to_xml_document().class.to_s
    assert_equal Nokogiri::XML.parse(
        `pdftohtml -stdout -xml "#{TEST_PDF_PATH}"`
      ).css('text').first.to_s,
       file.convert_to_document().css('text').first.to_s
  end
  
  def test_invalid_URL_pdffile
    e = assert_raise PDFToHTMLRError do
      file = PdfFileUrl.new("blah", ".", nil, nil)
    end
    assert_equal "invalid file url", e.to_s
  end
  
  def test_invalid_URL_resource_pdffile
    e = assert_raise PDFToHTMLRError do
      file = PdfFileUrl.new("http://zyx.com/kitplummer/blah", ".", nil, nil)
    end
    assert_equal "404 Not Found", e.to_s
  end
  
  def test_invalid_URL_pdf_pdffile
    e = assert_raise PDFToHTMLRError do
      file = PdfFileUrl.new(TEST_URL_NON_PDF, ".", nil, nil)
      file.convert
    end
    assert_equal "Error: May not be a PDF file (continuing anyway)", e.to_s
  end
  
  def test_valid_URL_pdffile
    # http://github.com/kitplummer/pdftohtmlr/raw/master/test/test.pdf
    file = PdfFileUrl.new(TEST_URL_PDF, ".", nil, nil)
    assert_equal "String", file.convert().class.to_s
    assert_equal `pdftohtml -stdout "#{TEST_PDF_PATH}"`, file.convert()
  end
  
  def test_args
    file = PdfFileUrl.new(TEST_URL_PDF)
    assert_equal "String", file.convert().class.to_s
  end
end