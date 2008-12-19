#!/usr/bin/env ruby
class LatexToImage
	attr_accessor :latexpreamble 

	def initialize(texstring, file, folder)
		@texinput = texstring
		@filename = file
		@foldername = folder
		@latexfooter = "\n\\end{displaymath} \n\\end{document}"
		@latexpreamble = "\\documentclass[12pt]{article} \n" +
							"\\pagestyle{empty} \n"
		@begindocument = "\n\\begin{document} \n" +
							"\\begin{displaymath}\n"
	end

	def process
		
		latex = @latexpreamble + @begindocument + @texinput + @latexfooter

		Dir.mkdir(@foldername) unless File::exists?(@foldername)
		Dir.chdir(@foldername)

		file = File.open(@filename + ".tex", "w+")
		file.puts latex
		file.close

		latexpipe = "echo x | latex " + @filename + ".tex" + ";"	
		dvips = "dvips -f " + @filename + ".dvi > " + @filename + ".ps" + ";"
		processPipe = " echo quit | gs -q -dNOPAUSE -r150x150 -sOutputFile=- -sDEVICE=pbmraw " + @filename + ".ps | " +
				"convert -trim -transparent white - " + @filename + ".png";
		cmd =  latexpipe + dvips + processPipe 

		IO.popen("#{cmd} 2>&1") do |f|
			while line = f.gets do
				puts line
			end
		end
		Dir.chdir("..")
	end
end

if ARGV.empty?
	puts "\nType in some latex string (in quotation marks)\n" + 	
		"and you will get a png file of the printed latex\n" +
		"output. Optionally you can supply a second string\n" +
		"as filename.\n\n"
	Process.exit
end

require "ftools"

# determine a filename
if ARGV[1] 
	filebase = ARGV[1]
else
	filebase = "LatexImage1"
	j = 2

	while File.exists?(filebase + ".png") do 
		filebase = "LatexImage" + j.to_s
		j += 1 
	end 
end


lti = LatexToImage.new(ARGV[0] ,filebase,"tmpfolder")
lti.latexpreamble += "\\usepackage{amsmath}"
lti.process
puts Dir.pwd
File.copy("tmpfolder/" + filebase + ".png", ".")
File.delete(*Dir["tmpfolder/*"])
Dir.rmdir("tmpfolder") 


