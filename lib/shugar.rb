def render(path)
  file = File.open(path, "rb")
  contents = file.read
  file.close
  contents
end

def fixture(file_name)
  File.expand_path("../lib/statics/#{file_name}", __FILE__)
end
