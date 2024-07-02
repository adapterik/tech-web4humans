require 'fileutils'
#
# I'm dreaming of becoming a Rakefile!
# 

puts "Installing npm dependencies in the codebase..."

file_sets = [
  {
    from_dir: 'font-awesome/css',
    to_dir: 'public/styles/vendor/font-awesome/css',
    files: [
      'font-awesome.css.map',
      'font-awesome.min.css'
    ]
  }, {
    from_dir: 'font-awesome/fonts',
    to_dir: 'public/styles/vendor/font-awesome/fonts',
    # this means to get all files
    all_files: true
  }, {
    from_dir: 'normalize.css',
    to_dir: 'public/styles/vendor/normalize.css',
    files: [
      'normalize.css'
    ]
  }, {
    from_dir: 'requirejs',
    to_dir: 'public/js/vendor/requirejs',
    files: [
      'require.js'
    ]
  }
]

file_sets.each do |file_set|
  FileUtils.mkpath file_set[:to_dir]
  if file_set.key? :all_files
    base = "node_modules/#{file_set[:from_dir]}"
    file_names = Dir.glob "#{base}/*", base: base
  else
    file_names = file_set[:files]
  end
  file_paths = file_names.map do |file|
    "node_modules/#{file_set[:from_dir]}/#{file}"
  end

  FileUtils.copy file_paths, file_set[:to_dir]
end