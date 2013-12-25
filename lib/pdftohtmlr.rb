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
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'tempfile'

module PDFToHTMLR
  
  # Simple local error abstraction
  class PDFToHTMLRError < RuntimeError; end
  
  VERSION = '0.4.2'

  # Provides facilities for converting PDFs to HTML from Ruby code.
  class PdfFile
    attr :path
    attr :target
    attr :user_pwd
    attr :owner_pwd
    attr :format
    
    def initialize(input_path, target_path=nil, user_pwd=nil, owner_pwd=nil)
      @path = input_path
      @target = target_path
      @user_pwd = user_pwd
      @owner_pwd = owner_pwd      
    end

    # Convert the PDF document to HTML.  Returns a string
    def convert()
      errors = ""
      output = ""
      
      if @user_pwd 
        cmd = "pdftohtml -stdout #{@format} -upw #{@user_pwd}" + ' "' + @path + '"'    
      elsif @owner_pwd 
        cmd = "pdftohtml -stdout #{@format} -opw #{@owner_pwd}" + ' "' + @path + '"'
      else
        cmd = "pdftohtml -stdout #{@format}" + ' "' + @path + '"'
      end
      
      output = `#{cmd} 2>&1`

      if (output.include?("Error: May not be a PDF file"))
        raise PDFToHTMLRError, "Error: May not be a PDF file (continuing anyway)"
      elsif (output.include?("Error:"))
        raise PDFToHTMLRError, output.split("\n").first.to_s.chomp
      else
        return output
      end
    end
    
    # Convert the PDF document to HTML.  Returns a Nokogiri::HTML:Document
    def convert_to_document() 
      Nokogiri::HTML.parse(convert())
    end
    
    def convert_to_xml()
      @format = "-xml"
      convert()
    end
    
    def convert_to_xml_document()
      @format = "-xml"
      Nokogiri::XML.parse(convert())
    end
  end
  
  # Handle a string-based local path as input, extends PdfFile
  class PdfFilePath < PdfFile
    def initialize(input_path, target_path=nil, user_pwd=nil, owner_pwd=nil)
      # check to make sure file is legit
      if (!File.exist?(input_path))
        raise PDFToHTMLRError, "invalid file path"
      end
      
      super(input_path, target_path, user_pwd, owner_pwd)
      
    end 
  end
  
  # Handle a URI as a remote path to a PDF, extends PdfFile
  class PdfFileUrl < PdfFile
    def initialize(input_url, target_path=nil, user_pwd=nil, owner_pwd=nil)
      # check to make sure file is legit
      begin
        if ((input_url =~ URI::regexp).nil?)
          raise PDFToHTMLRError, "invalid file url"
        end
        tempfile = Tempfile.new('pdftohtmlr')
        File.open(tempfile.path, 'wb') {|f| f.write(open(input_url).read) }
        super(tempfile.path, target_path, user_pwd, owner_pwd)
      rescue => bang
        raise PDFToHTMLRError, bang.to_s
      end
    end
  end
end