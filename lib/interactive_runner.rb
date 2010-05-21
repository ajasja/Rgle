
file_name = ARGV[0]
raise "file #{file_name} does not exist!" unless file_name

mtime = File.mtime(file_name)
puts Dir.pwd
while true do
  sleep(0.1)
  if mtime != File.mtime(file_name) then
    mtime = File.mtime(file_name)
    load file_name
  end
end
