# frozen_string_literal: true

namespace :unparser do
  desc "Ensure there's a local copy of mbj/unparser"
  file "tmp/unparser" do
    sh "git clone --depth=1 https://github.com/mbj/unparser tmp/unparser"
  end

  desc "Ensure we have a fixtures directory for the unparser tests"
  file "test/yarp/fixtures/unparser" do
    mkdir_p "test/yarp/fixtures/unparser"
  end

  desc "Import the unparser tests"
  task import: ["tmp/unparser", "test/yarp/fixtures/unparser"] do
    cp "tmp/unparser/LICENSE", "test/yarp/fixtures/unparser/LICENSE"
    cp_r "tmp/unparser/test/corpus/", "test/yarp/fixtures/unparser"

    Dir["test/yarp/fixtures/unparser/**/*.rb"].each do |f|
      File.rename(f, f.sub(/\.rb$/, ".txt"))
    end

    # There's an issue with one of the test files in unparser. We'll correct it
    # until https://github.com/mbj/unparser/issues/340 is closed.
    filepath = "test/yarp/fixtures/unparser/corpus/literal/pattern.txt"
    File.write(filepath, File.read(filepath).gsub("\"\#{\"a\"}\"", "\"a\""))

    # These files are not valid Ruby
    known_failures = %w[
      test/yarp/fixtures/unparser/corpus/literal/binary.txt
    ]

    # Remove all invalid Ruby files
    known_failures.each { rm _1 }
  end

  desc "Clean up tmp files related to unparser"
  task :clean do
    rm_rf "tmp/unparser"
    rm_rf "test/yarp/fixtures/unparser"
  end
end
