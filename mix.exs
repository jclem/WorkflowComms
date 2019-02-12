defmodule SlackActionsUmbrella.MixProject do
  use Mix.Project

  @vsn "1.0.0"

  def project do
    [
      apps_path: "apps",
      version: @vsn,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [{:distillery, "~> 1.5.0"}]
  end
end
