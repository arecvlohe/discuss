defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  alias Discuss.Topic
  alias Discuss.Comment

  plug Discuss.Plugs.RequireAuth when action in [:new, :edit, :create, :update, :delete, :create_comment]
  plug :check_topic_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"topic" => topic}) do
    changeset = conn.assigns.user
      |> build_assoc(:topics)
      |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic was successfully saved!")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
    
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)
    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic successfully updated!")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: old_topic
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic successfully deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id }} = conn

    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else 
      conn
      |> put_flash(:error, "You cannot edit that")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end

  def show(conn, %{"id" => topic_id}) do
    topic = Repo.get!(Topic, topic_id)
    comments = Repo.all(from(c in Comment, where: c.topic_id == ^topic_id))
    changeset = Comment.changeset(%Comment{}, %{})
    
    render conn, "show.html", topic: topic, changeset: changeset, comments: comments
  end

  
  def create_comment(conn, %{"comment" => comment}) do
    topic = Repo.get!(Topic, comment["topic_id"])
    comments = Repo.all(from(c in Comment, where: c.topic_id == ^comment["topic_id"]))
    changeset = build_assoc(topic, :comments, %{user_id: conn.assigns.user.id}) |> Comment.changeset(comment)
    
    case Repo.insert(changeset) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment was successfully saved!")
        |> redirect(to: topic_path(conn, :show, comment["topic_id"]))
      {:error, changeset} ->
        render conn, "show.html", topic: topic, changeset: changeset, comments: comments
    end
  end

end
