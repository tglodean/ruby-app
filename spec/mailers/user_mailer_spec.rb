require "spec_helper"

describe UserMailer do
  before do
    @user = User.new(name: "Example User", email: "user@example.com",
     password: "foobar", password_confirmation: "foobar")
  end
  describe "password_reset" do
    before do
      @user.password_reset_token = User.digest(User.new_remember_token)
      @user.save
    end
    let(:user) { User.find_by_email(@user.email)}
    let(:mail) { UserMailer.password_reset(user) }

    it "renders the headers" do
      mail.subject.should eq("Password reset")
      mail.to.should eq(["user@example.com"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("password")
    end
  end

end
