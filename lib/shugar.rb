def render(path)
  file = File.open(path, "rb")
  contents = file.read
  file.close
  contents
end
