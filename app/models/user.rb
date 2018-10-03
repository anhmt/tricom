class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader
  self.table_name = :担当者マスタ
  self.primary_key = :担当者コード
  CSV_HEADERS = %w(担当者コード 担当者名称 admin email supervisor)
  include PgSearch
  multisearchable against: %w{担当者コード 担当者名称}
  attr_accessor :current_password
  attr_accessor :flag_reset_password
  attr_accessor :remember_token
  # validates :email, confirmation: true
  # validates :email_confirmation, presence: true
  belongs_to :shainmaster, foreign_key: :担当者コード
  has_many :conversations, foreign_key: :sender_id
  has_many :messages, foreign_key: 'user', dependent: :destroy
  alias_attribute :id, :担当者コード
  alias_attribute :name, :担当者名称
  validates :password, length: { minimum: 4 }, allow_blank: true
  # validates :担当者コード, uniqueness: true, presence: true
  validate :check_taken, on: :create
  validates :担当者名称, presence: true
  validates :担当者コード, presence: true
  validates_format_of :email, with: /(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z)|(^$)/i, message: I18n.t('errors.messages.wrong_mail_form')
  validate :current_password_is_correct, on: :update
  has_secure_password

  def check_taken
    if 担当者コード.present? && 担当者コード.in?(User.pluck(:担当者コード))
      errors.add(:担当者コード, (I18n.t 'errors.messages.taken'))
    elsif 担当者コード.present? && !担当者コード.in?(Shainmaster.pluck(:社員番号))
      errors.add(:担当者コード, (I18n.t 'errors.messages.invalid'))
    elsif !担当者コード.present?
      errors.add(:担当者コード, '')
    end
  end

  def self.import(file)
    # a block that runs through a loop in our CSV data
    CSV.foreach(file.path, headers: true) do |row|
      # creates a user for each row in the CSV file
      @user_info = row.to_hash
      @user_info['password'] = @user_info['担当者コード']
      @user_info['password_confirmation'] = @user_info['担当者コード']
      User.create @user_info
    end
  end
  # Check if the inputted current password is correct when the user tries to update his/her password
  def current_password_is_correct
    # Check if the user tried changing his/her password
    if password.present?
      # Get a reference to the user since the "authenticate" method always returns false when calling on itself (for some reason)
      user = User.find_by_id(id)

      # Check if the user CANNOT be authenticated with the entered current password
      if (user.authenticate(current_password) == false) && flag_reset_password != true
        # Add an error stating that the current password is incorrect
        errors.add(:current_password, I18n.t('errors.messages.current_password_incorrect'))
      end
    end
  end

  # Get avatar url
  def avatar_link
    avatar? ? avatar_url : AvatarUploader::DEFAULT_URL
  end
end
