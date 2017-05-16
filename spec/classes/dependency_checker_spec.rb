require 'rails_helper'

describe DependencyChecker do
  describe '#initialize' do
    context "when the informed args are not related" do
      subject {
        described_class.new(
          team: build(:team),
          user: build(:user),
          exercise: build(:exercise)
        )
      }

      it { expect { subject }.to raise_error(RuntimeError) }
    end

    context "when the informed args are related" do
      it "doesn't raises an error" do
        args = related_args

        expect {
          described_class.new(
            user: args[:user],
            exercise: args[:exercise],
            team: args[:team])
        }.to_not raise_error
      end
    end
  end

  describe '#user_able_to_answer?' do
    context "when question doesn't belongs to the specified exercise" do
      subject {
        described_class.new(
          team: build(:team),
          user: build(:user),
          exercise: build(:exercise)
        ).user_able_to_answer?(build(:question))
      }

      it { expect { subject }.to raise_error(RuntimeError) }
    end

    context "when question belongs to the specified exercise" do
      context "when all dependencies are satisfied" do
        it "returns true" do
          args = related_args
          questions = create_list(:question, 5, exercise: args[:exercise])

          set_dependencies(questions)
          create_right_answers([questions[0], questions[3], questions[4]], args)

          result = described_class.new(
            team: args[:team],
            user: args[:user],
            exercise: args[:exercise]
          ).user_able_to_answer?(questions[1])

          expect(result).to be_truthy
        end
      end

      context "when dependencies aren't satisfied" do
        context "when only AND dependencies are satisfied" do
          it "returns false" do
            args = related_args
            questions = create_list(:question, 5, exercise: args[:exercise])

            set_dependencies(questions)
            create_right_answers([questions[2], questions[3]], args)

            result = described_class.new(
              team: args[:team],
              user: args[:user],
              exercise: args[:exercise]
            ).user_able_to_answer?(questions[1])

            expect(result).to be_falsey
          end
        end

        context "when only OR dependencies are satisfied" do
          it "returns false" do
            args = related_args
            questions = create_list(:question, 5, exercise: args[:exercise])

            set_dependencies(questions)
            create_right_answers([questions[0]], args)

            result = described_class.new(
              team: args[:team],
              user: args[:user],
              exercise: args[:exercise]
            ).user_able_to_answer?(questions[1])

            expect(result).to be_falsey
          end
        end

        context "when none dependency is satisfied" do
          it "returns false" do
            args = related_args
            questions = create_list(:question, 5, exercise: args[:exercise])

            set_dependencies(questions)

            result = described_class.new(
              team: args[:team],
              user: args[:user],
              exercise: args[:exercise]
            ).user_able_to_answer?(questions[1])

            expect(result).to be_falsey
          end
        end
      end
    end
  end

  describe 'questions_able_to_answer' do
    it "returns questions without dependency issues" do
      args = related_args
      questions = create_list(:question, 5, exercise: args[:exercise])

      set_dependencies(questions)

      result = described_class.new(
        team: args[:team],
        user: args[:user],
        exercise: args[:exercise]
      ).questions_able_to_answer

      expected = [questions[0], questions[2], questions[3], questions[4]]

      expect(result).to eq expected
    end
  end

  # Share common data setup for tests. Describing:
  # 0 is able if answered (0 OR 2) AND (3 AND 4)
  def set_dependencies(questions)
    create(
      :question_dependency,
      question_1: questions[1],
      question_2: questions[0],
      operator: "OR"
    )

    create(
      :question_dependency,
      question_1: questions[1],
      question_2: questions[2],
      operator: "OR"
    )

    create(
      :question_dependency,
      question_1: questions[1],
      question_2: questions[3],
      operator: "AND"
    )

    create(
      :question_dependency,
      question_1: questions[1],
      question_2: questions[4],
      operator: "AND"
    )
  end

  def create_right_answers(questions, args)
    questions.each { |question|
      create(
        :answer, :correct,
        user: args[:user],
        team: args[:team],
        question: question
      )
    }
  end

  def related_args
    team = create(:team)
    exercise = create(:exercise, teams: [team])
    user = create(:user, teams: [team])

    { team: team, exercise: exercise, user: user }
  end
end
