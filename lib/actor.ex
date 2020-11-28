defmodule Bonfire.Data.ActivityPub.Actor do
  @moduledoc """
  
  """

  use Pointers.Mixin,
    otp_app: :bonfire_data_activity_pub,
    source: "bonfire_data_activity_pub_actor"

  alias Bonfire.Data.ActivityPub.Actor
  alias Pointers.Changesets

  mixin_schema do
    field :signing_key, :string
  end

  @defaults [
    cast: [:signing_key],
    required: [:signing_key]
  ]

  def changeset(actor \\ %Actor{}, attrs, opts \\ []) do
    Changesets.auto(actor, attrs, opts, @defaults)
  end

end
defmodule Bonfire.Data.ActivityPub.Actor.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.ActivityPub.Actor

  @actor_table Actor.__schema__(:source)

  # create_actor_table/{0,1}

  defp make_actor_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.ActivityPub.Actor) do
        Ecto.Migration.add :signing_key, :text
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_actor_table(), do: make_actor_table([])
  defmacro create_actor_table([do: {_, _, body}]), do: make_actor_table(body)

  # drop_actor_table/0

  def drop_actor_table(), do: drop_pointable_table(Actor)

  # migrate_actor/{0,1}

  defp ma(:up), do: make_actor_table([])
  defp ma(:down) do
    quote do: Bonfire.Data.ActivityPub.Actor.Migration.drop_actor_table()
  end

  defmacro migrate_actor() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ma(:up)),
        else: unquote(ma(:down))
    end
  end
  defmacro migrate_actor(dir), do: ma(dir)

end
