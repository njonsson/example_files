defmodule ExampleFiles.FileSpec do
  use ESpec, async: true

  # TODO: Figure out why `warn: false` is necessary despite references below that fail to compile without this alias
  alias ExampleFiles.File, warn: false

  describe ".name_match?" do
    describe "returning false" do
      let :expected, do: false

      describe ~s(for "foo") do
        subject do: File.name_match? "foo"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "example") do
        subject do: File.name_match? "example"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "fooexample") do
        subject do: File.name_match? "fooexample"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "examplefoo") do
        subject do: File.name_match? "examplefoo"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "foo.example/bar") do
        subject do: File.name_match? "foo.example/foo"

        it do: is_expected.to eq(expected)
      end
    end

    describe "returning true" do
      let :expected, do: true

      describe ~s(for "foo.example") do
        subject do: File.name_match? "foo.example"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "fooExample") do
        subject do: File.name_match? "fooExample"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "example.foo") do
        subject do: File.name_match? "example.foo"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "exampleFoo") do
        subject do: File.name_match? "exampleFoo"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "example123") do
        subject do: File.name_match? "example123"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "foo.Example") do
        subject do: File.name_match? "foo.Example"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "Example.foo") do
        subject do: File.name_match? "Example.foo"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "ExampleFoo") do
        subject do: File.name_match? "ExampleFoo"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "Example123") do
        subject do: File.name_match? "Example123"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "foo.EXAMPLE") do
        subject do: File.name_match? "foo.EXAMPLE"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "EXAMPLE.foo") do
        subject do: File.name_match? "EXAMPLE.foo"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "foo.example.bar") do
        subject do: File.name_match? "foo.example.bar"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "fooExampleBar") do
        subject do: File.name_match? "fooExampleBar"

        it do: is_expected.to eq(expected)
      end

      describe ~s(for "123Example456") do
        subject do: File.name_match? "123Example456"

        it do: is_expected.to eq(expected)
      end
    end
  end
end
