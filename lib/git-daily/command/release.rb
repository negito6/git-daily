        @base_branch = Command.develop
        @merge_to = [Command.main, Command.develop]
                          Command.remote_branch(remote, Command.main)
                          Command.main