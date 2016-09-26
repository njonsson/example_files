defmodule ExampleFilesSpec do
  use ESpec, async: false

  describe ".find --" do
    let :result_glob, do: result |> elem(0)

    let :result_noncollisions, do: result |> elem(1)

    let :result_collisions, do: result |> elem(2)

    let :result, do: ExampleFiles.find List.wrap(filespecs)

    let :filespecs, do: []

    describe "glob, when given" do
      subject do: result_glob

      describe "no filespecs --" do
        it do: is_expected.to eq("**/*{example,Example,EXAMPLE}*")
      end

      describe "filespecs --" do
        let :filespecs, do: ~w(foo bar)

        it do: is_expected.to eq("{foo,bar}/*{example,Example,EXAMPLE}*")
      end
    end

    describe "when there are" do
      describe "no example files --" do
        let :fixtures_path, do: "spec/fixtures/empty"

        describe "noncollisions" do
          subject do: result_noncollisions

          it do
            File.cd! fixtures_path, fn ->
              is_expected.to eq([])
            end
          end
        end

        describe "collisions" do
          subject do: result_collisions

          it do
            File.cd! fixtures_path, fn ->
              is_expected.to eq(%{})
            end
          end
        end
      end

      describe "example files" do
        describe "without collisions, and filespecs" do
          let :fixtures_path, do: "spec/fixtures/no_collisions"

          describe "include them --" do
            describe "noncollisions" do
              subject do: result_noncollisions

              it do
                File.cd! fixtures_path, fn ->
                  is_expected.to eq([{false, "file.example", "file"}])
                end
              end
            end

            describe "collisions" do
              subject do: result_collisions

              it do
                File.cd! fixtures_path, fn ->
                  is_expected.to eq(%{})
                end
              end
            end
          end

          describe "exclude them --" do
            let :filespecs, do: "NOPE"

            describe "noncollisions" do
              subject do: result_noncollisions

              it do
                File.cd! fixtures_path, fn ->
                  is_expected.to eq([])
                end
              end
            end

            describe "collisions" do
              subject do: result_collisions

              it do
                File.cd! fixtures_path, fn ->
                  is_expected.to eq(%{})
                end
              end
            end
          end
        end

        describe "with collisions, and filespecs" do
          let :fixtures_path, do: "spec/fixtures/collisions"

          describe "include them --" do
            describe "noncollisions" do
              subject do: result_noncollisions

              it do
                File.cd! fixtures_path, fn ->
                  is_expected.to eq([{false, "file2.example", "file2"}])
                end
              end
            end

            describe "collisions" do
              subject do: result_collisions |> Map.keys

              it do
                File.cd! fixtures_path, fn -> is_expected.to eq(["file1"]) end
              end

              describe "on file1" do
                subject do: result_collisions["file1"]

                it do
                  File.cd! fixtures_path, fn ->
                    is_expected.to have({false, "file1.example", "file1"})
                    is_expected.to have({false, "EXAMPLE-file1", "file1"})
                  end
                end
              end
            end
          end

          describe "exclude them --" do
            let :filespecs, do: "NOPE"

            describe "noncollisions" do
              subject do: result_noncollisions

              it do
                File.cd! fixtures_path, fn ->
                  is_expected.to eq([])
                end
              end
            end

            describe "collisions" do
              subject do: result_collisions

              it do
                File.cd! fixtures_path, fn ->
                  is_expected.to eq(%{})
                end
              end
            end
          end
        end
      end
    end
  end
end
