class Task < ApplicationRecord
    validates :title,:detail, null:false,presence: true, length: { minimum: 1 }

    belongs_to :user
    has_many :labelings, dependent: :destroy
    has_many :labels, through: :labelings, source: :label

    enum status: {
        unstarted: 0,
        progress: 1,
        completed: 2
    }
    enum priority: {
        Low: 0,
        Medium:1,
        High: 2
    }
    scope :label_sort, -> (search_label){
        tasks = Labeling.where(label_id: search_label)
        ids = tasks.map{ |task| task.task_id } 
        where(id: ids)
    }
    scope :ordered, -> { order(created_at: :desc) }
    scope :orderByDeadline,->{order(deadline: :desc) }
    scope :orderByPriority,->{order(priority: :desc) }
    
    scope :status_sort, -> (search_status){ where(status: search_status) }

    scope :search_sort, -> (search_word){ where('title LIKE ?', "%#{search_word}%") }

    scope :priority_sort, -> (search_priority){ where(priority: search_priority) }

     scope :kaminari, -> (kaminari_page){ page(kaminari_page).per(5) }
     scope :current_user_sort,->(current_user_id){where(user_id: current_user_id)}
end
