require 'rubygems'
require 'open3'

module PDFToHTMLR
  class PDFToHTMLRError < RuntimeError; end

  VERSION = '0.2.0'

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
    
  end
end