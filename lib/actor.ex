defmodule CommonsPub.Actors.Actor do
  @moduledoc """
  
  """

  use Pointers.Mixin,
    otp_app: :cpub_actors,
    source: "cpub_actors_actor"

  alias CommonsPub.Actors.Actor
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
defmodule CommonsPub.Actors.Actor.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Actors.Actor

  # @actor_table Actor.__schema__(:source)

  def migrate_actor(dir \\ direction())

  def migrate_actor(:up) do
    create_mixin_table(Actor) do
      add :signing_key, :text
    end
  end

  def migrate_actor(:down) do
    drop_mixin_table(Actor)
  end

end
