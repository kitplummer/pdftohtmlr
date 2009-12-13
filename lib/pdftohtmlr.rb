# The library has a single method for converting PDF files into HTML. The
# method current takes in the source path, and either/both the user and owner
# passwords set on the source PDF document.  The convert method returns the
# HTML as a string for further manipulation of loading into a Document.
#
# Requires that pdftohtml be installed and on the path
#
# Author:: Kit Plummer (mailto:kitplummer@gmail.com)
# Copyright:: Copyright (c) 2009 Kit Plummer
# License:: MIT

require 'rubygems'
require 'open3'
require 'nokogiri'

module PDFToHTMLR
  
  # Simple local error abstraction
  class PDFToHTMLRError < RuntimeError; end
  
  VERSION = '0.2.0'

  # Provides facilities for converting PDFs to HTML from Ruby code.
  class PdfFile
    attr :path
    attr :target
    attr :user_pwd
    attr :owner_pwd

    def initialize(input_path, target_path, user_pwd, owner_pwd)
      @path = input_path
      @target = target_path
      @user_pwd = user_pwd
      @owner_pwd = owner_pwd

      # check to make sure file is legit
      if (!File.exist?(@path))
        raise PDFToHTMLRError, "invalid file path"
      end
      
    end

    # Convert the PDF document to HTML.  Returns a string
    def convert()
      errors = ""
      output = ""
      if @user_pwd 
        cmd = "pdftohtml -stdout -upw #{@user_pwd} #{@path}"    
      elsif @owner_pwd 
        cmd = "pdftohtml -stdout -opw #{@owner_pwd} #{@path}"
      else
        cmd = "pdftohtml -stdout #{@path}"
      end
      
      Open3.popen3 cmd do | stdin, stdout, stderr|
        stdin.write cmd
        stdin.close
        output = stdout.read
        errors = stderr.read
      end

      if (errors != "")
        raise PDFToHTMLRError, errors.to_s
      else
        return output
      end
    end
    
    # Convert the PDF document to HTML.  Returns a Nokogiri::HTML:Document
    def convert_to_document() 
      Nokogiri::HTML.parse(convert())
    end
    
  end
end