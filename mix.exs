Code.eval_file("mess.exs")

defmodule Bonfire.Data.ActivityPub.MixProject do
  use Mix.Project

  def project do
    [
      app: :bonfire_data_activity_pub,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      description: "Actor-related models for bonfire",
      homepage_url:
        "https://github.com/bonfire-networks/bonfire_data_activity_pub",
      source_url:
        "https://github.com/bonfire-networks/bonfire_data_activity_pub",
      package: [
        licenses: ["MPL 2.0"],
        links: %{
          "Repository" =>
            "https://github.com/bonfire-networks/bonfire_data_activity_pub",
          "Hexdocs" => "https://hexdocs.pm/bonfire_data_activity_pub"
        }
      ],
      docs: [
        # The first page to display from the docs
        main: "readme",
        # extra pages to include
        extras: ["README.md"]
      ],
      deps: Mess.deps([{:ex_doc, ">= 0.0.0", only: :dev, runtime: false}])
    ]
  end

  def application, do: [extra_applications: [:logger]]
end
