package = "enkoder"
version = "1.0-0"
source = {
   type = "git",
   url = "https://github.com/RixInGithub/enkoder.git",
   branch = "main"
}
description = {
   homepage = "https://github.com/RixInGithub/enkoder#readme",
   license = "AGPL-v3.0"
}
build = {
   type = "builtin",
   modules = {
      init = "init.lua"
   }
}
