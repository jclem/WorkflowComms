ExUnit.start()

{:ok, files} = File.ls("./test/support")
Enum.each(files, &Code.require_file("support/#{&1}", __DIR__))
