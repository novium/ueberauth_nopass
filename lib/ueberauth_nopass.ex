defmodule UeberauthNopass do
  use Application

  @moduledoc false
  # TODO: Add configuration option to set paths

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(UeberauthNopass.Store, name: Store)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defmacro mount_html do
    quote do
      require Ueberauth

      scope "/nopass", UeberauthNopass.Controller.View do
        get "/do", Authenticate, :new
      end
    end
  end

  defmacro mount_api do
    quote do
      require Ueberauth

      scope "/nopass", UeberauthNopass.Controller.API do
        post "/send", Authenticate, :send
      end
    end
  end
end
