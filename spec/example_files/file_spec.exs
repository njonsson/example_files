defmodule ExampleFiles.FileSpec do
  use ESpec, async: true

  use Doctest

  let :file do
    {:ok, pid} = described_module.start_link([path])
    pid
  end

  let :path, do: "#{path_when_pulled}.example"

  let :path_when_pulled, do: Path.join System.tmp_dir!, random_numerals

  let :random_numerals, do: String.slice(to_string(:rand.uniform), 2..-1)

  describe "where the example file does not exist" do
    describe ".status" do
      subject do: file |> described_module.status

      it do: is_expected.to eq(:missing)
    end

    describe ".pull" do
      subject! do: file |> described_module.pull

      finally do: path_when_pulled |> File.rm

      specify do: expect(File.exists?(path_when_pulled)).to eq(false)

      it do: is_expected.to eq({:error, :enoent})
    end

    describe ".clean" do
      subject! do: file |> described_module.clean

      specify do: expect(File.exists?(path_when_pulled)).to eq(false)

      it do: is_expected.to eq({:ok, :enoent})
    end
  end

  describe "where the example file exists, and the copy" do
    before do: path |> File.touch!

    finally do: path |> File.rm

    describe "does not exist" do
      describe ".status" do
        subject do: file |> described_module.status

        it do: is_expected.to eq(:missing)
      end

      describe ".pull" do
        subject! do: file |> described_module.pull

        finally do: path_when_pulled |> File.rm

        it do: expect(File.exists?(path_when_pulled)).to eq(true)

        it do: is_expected.to eq({:ok, :copied})
      end

      describe ".clean" do
        subject! do: file |> described_module.clean

        finally do: path_when_pulled |> File.rm

        it do: expect(File.exists?(path_when_pulled)).to eq(false)

        it do: is_expected.to eq({:ok, :enoent})
      end
    end

    describe "is identical" do
      before do: path_when_pulled |> File.touch!

      finally do: path_when_pulled |> File.rm

      describe ".status" do
        subject do: file |> described_module.status

        it do: is_expected.to eq(:identical)
      end

      describe ".pull" do
        subject! do: file |> described_module.pull

        specify do: expect(File.exists?(path_when_pulled)).to eq(true)

        it do: is_expected.to eq({:ok, :identical})
      end

      describe ".clean" do
        subject! do: file |> described_module.clean

        specify do: expect(File.exists?(path_when_pulled)).to eq(false)

        it do: is_expected.to eq({:ok, :deleted})
      end
    end

    describe "is different" do
      before do: path_when_pulled |> File.write!("foo")

      finally do: path_when_pulled |> File.rm

      describe ".status" do
        subject do: file |> described_module.status

        it do: is_expected.to eq(:out_of_date)
      end

      describe ".pull" do
        subject! do: file |> described_module.pull

        specify do: expect(File.exists?(path_when_pulled)).to eq(true)

        it do: is_expected.to eq({:ok, :copied})
      end

      describe ".clean" do
        subject! do: file |> described_module.clean

        specify do: expect(File.exists?(path_when_pulled)).to eq(false)

        it do: is_expected.to eq({:ok, :deleted})
      end
    end
  end
end
