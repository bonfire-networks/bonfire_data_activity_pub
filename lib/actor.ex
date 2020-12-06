defmodule Bonfire.Data.ActivityPub.Actor do
  @moduledoc """
  
  """

  use Pointers.Mixin,
    otp_app: :bonfire_data_activity_pub,
    source: "bonfire_data_activity_pub_actor"

  alias Bonfire.Data.ActivityPub.{Actor, Peer}
  alias Pointers.Changesets

  mixin_schema do
    field :signing_key, :string
    has_one :peer, Peer, references: :id
  end

  @defaults [
    cast: [:signing_key, :peer_id],
    required: []
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
      Pointers.Migration.create_mixin_table(Bonfire.Data.ActivityPub.Actor) do
        Ecto.Migration.add :signing_key, :text
        Ecto.Migration.add :peer_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.ActivityPub.Peer)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_actor_table(), do: make_actor_table([])
  defmacro create_actor_table([do: {_, _, body}]), do: make_actor_table(body)

  # drop_actor_table/0

  def drop_actor_table(), do: drop_mixin_table(Actor)

  defp make_actor_peer_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@actor_table), [:peer_id], unquote(opts))
      )
    end
  end

  defmacro create_actor_peer_index(opts \\ [])
  defmacro create_actor_peer_index(opts), do: make_actor_peer_index(opts)

  def drop_actor_peer_index(opts \\ []) do
    drop_if_exists(index(@actor_table, [:peer_id], opts))
  end

  # migrate_actor/{0,1}

  defp ma(:up) do
    quote do
      unquote(make_actor_table([]))
      unquote(make_actor_peer_index([]))
    end
  end
  defp ma(:down) do
    quote do
      Bonfire.Data.ActivityPub.Actor.Migration.drop_actor_peer_index()
      Bonfire.Data.ActivityPub.Actor.Migration.drop_actor_table()
    end
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
