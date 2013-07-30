def get_apocalyptic_warning_excerpt()
  "## BEGIN ##
      Auto generated includes, do not modify or it will explode and kill you and everyone you love.
    -->

    ### INCLUDES ###

    <!--
      The end of the auto generated includes, you are safe from now on.
      ## END ##"
end

def generate_includes(files, url = '')
  _files = files.split("\n")

  index = _files.select { |e|
    (e =~ /.*\index.js$/)
  }

  _files.select { |e|
    (e =~ /.*\.js$/) and ! (e =~ /.*\index.js$/)
  }.push(index[0])
  .map { |f|
    "    <script src=\""+url+f+"\"></script>"
  }.join "\n"
end

def generate_includes_excerpt(files, url)
  apoc_war = get_apocalyptic_warning_excerpt()
  includes = generate_includes files, url
  apoc_war.gsub '    ### INCLUDES ###', includes
end

def output_updated_file(original_file_contents, includes_section, output_file)
  modified_file_contents = original_file_contents.gsub(/## BEGIN ##.*## END ##/m, includes_section)
  File.open(output_file, 'w') { |file| file.write modified_file_contents }
end

def update_index_includes(files, url, output_file)
  includes_section = generate_includes_excerpt files, url
  original_file_contents = File.read output_file

  output_updated_file original_file_contents, includes_section, output_file
end

update_index_includes `find js`, '', 'dev.html'
