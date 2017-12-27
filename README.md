# UeberauthNopass

Adds the option to use email-based authentication for ueberauth. Requires a
SMTP server to send emails.

When authenticating the user recieves an email with a link/key that is used
to login.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ueberauth_nopass` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ueberauth_nopass, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ueberauth_nopass](https://hexdocs.pm/ueberauth_nopass).

