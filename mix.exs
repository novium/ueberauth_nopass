defmodule UeberauthNopass.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ueberauth_nopass,
      version: "0.1.0",
      name: "Ueberauth Nopass",
      package: package(),
      elixir: "~> 1.5",
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      build_embedded: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {UeberauthNopass, []},
      extra_applications: [:logger, :gettext, :phoenix, :phoenix_html, :ueberauth, :bamboo, :bamboo_smtp]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.0"},
      {:phoenix, "~> 1.2"},
      {:phoenix_html, "~> 2.10"},
      {:gettext, "~> 0.11"},

      {:bamboo, "~> 0.8.0"},
      {:bamboo_smtp, "~> 1.4"},



      {:ueberauth, "~> 0.4.0"}
    ]
  end

  defp package do
    [files: "",
     maintainers: ["Alexander Troshin"],
     licenses: ["MIT"]]
  end
end
