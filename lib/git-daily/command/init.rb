# -*- coding: utf-8 -*-

require "git-daily/command"

module Git
  module Daily
    class Init < Command

      def option
        OptionParser.new
      end

      def help
        "init\tInitialize git daily"
      end

      def run
        r = `git config --bool gitdaily.init`
        if r.chomp == "true"
          # initialized repo
          return nil
        end
        remotes = `git config --list`.split(/\n/).select {|a| a[/^remote\.([^\.]+)\.url/] }
        if remotes.empty?
          raise "don't have remote repojitory"
        end

        remotes.map! {|r| r[/^remote\.([^\.]+)\.url=(.*)/, 1] }

        selected_url = nil
        if remotes.size >= 2
          puts "Choose your remote url:"
          i = 0
          remotes.each do |v|
            puts "    #{i}: #{v}"
            i += 1
          end
          print "    > "
          n = gets.to_i
          selected_url = remotes[n]
        else
          selected_url = remotes[0]
        end

        r = `git config gitdaily.remote #{selected_url}`
        puts "Your remote is [#{selected_url}]"
        Git::Daily.application.remote = selected_url

        # master branch
        print "Name master branch [master]: "
        master = gets.strip
        if master.empty?
          master = "master"
        end
        `git checkout #{master} && git checkout -`
        `git config gitdaily.master #{master}`

        # develop branch
        set_branch("develop", default: "develop")

        # initialized
        `git config gitdaily.init true`

        puts
        puts "git-daily completed to initialize."
        selected_url
      end

      def usage
        <<-EOS
Usage: git daily init
EOS
      end

      private

      def set_branch(name, default: nil)
        default ||= name

        print "Name #{name} branch [#{name}]: "
        branch = gets.strip
        if branch.empty?
          branch = default
        end
        `git config gitdaily.#{name} #{branch}`

        unless Command.has_branch? branch
          remote = Command.remote
          if remote and Command.has_remote_branch?(remote, branch)
            `git checkout #{branch}`
          else
            `git checkout -b #{branch}`
            if remote
              `git push #{remote} #{branch}`
            end
          end
        end

      end
    end
  end
end
