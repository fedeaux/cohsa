require 'fileutils'

class CohsaCommandLineParser
  def initialize(argv)
    args = argv[1..-1]
    @command = argv[0]
    @base_dir = File.dirname(__FILE__).gsub(/tools$/, '')

    if CohsaCommandLineParser.method_defined? @command
      self.send @command, args
    else
      puts 'I don\'t know what you mean by "'+@command+'"'
    end
  end

  def create(args)
    if args.length == 0
      puts 'cohsa create target_directory'
      exit
    end

    dir_name = args[0]
    Dir::mkdir(dir_name) unless File.directory? dir_name

    unless Dir[dir_name+'/*'].empty?
      puts dir_name+' already exists and its not empty.'
    end

    
    FileUtils::cp_r Dir[@base_dir+'framework/*'], dir_name
  end

  def help(args)
    puts "Help! I need somebody
          Help! Not just anybody
          Help! You know I need someone
          Help!
          
          When I was younger so much younger than today
          I never needed anybody's help in any way
          But now these days are gone 
          I'm not so self assured
          Now I find I've changed my mind 
          I've opened up the doors
          
          Help me if you can I'm feeling down
          And I do appreciate you being 'round
          Help me get my feet back on the ground
          Won't you please, please, help me?
          
          And now my life has changed in so many ways
          My independence seems to vanish in the haze
          But every now and then I feel so insecure
          I know that I just need you like
          I've never done before
          
          Help me if you can I'm feeling down
          And I do appreciate you being 'round
          Help me get my feet back on the ground
          Won't you please, please, help me?
          
          When I was younger so much younger than today
          I never needed anybody's help in any way
          But now these days are gone 
          I'm not so self assured
          Now I find I've changed my mind 
          I've opened up the doors
          
          Help me if you can I'm feeling down
          And I do appreciate you being 'round
          Help me get my feet back on the ground
          Won't you please, please, help me, help me, help me?
          Oh"
  end
end
