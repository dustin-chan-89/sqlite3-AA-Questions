class Question
  attr_accessor :id, :title, :body, :user_id

  def initialize(options = {})
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end

  def author
    User.find_by_id(user_id)
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end

  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def save
    if id
      QuestionsDatabase.instance.execute(<<-SQL, title, body, user_id, id)
        UPDATE
          questions
        SET
          title = ?,
          body = ?,
          user_id = ?
        WHERE
          id = ?
      SQL
    else
      QuestionsDatabase.instance.execute(<<-SQL, title, body, user_id)
        INSERT INTO
          questions(title, body, user_id)
        VALUES
          (?, ?, ?)
      SQL
      self.id = QuestionsDatabase.instance.last_insert_row_id
    end
  end
end
