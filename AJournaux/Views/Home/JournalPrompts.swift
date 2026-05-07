import Foundation

struct JournalPrompts {
    static let all: [String] = [
        "One of the things you are proud to do today.",
        "What made you smile today?",
        "What did you learn today?",
        "What are you grateful for today?",
        "What was the best part of your day?",
        "What challenged you today and how did you handle it?",
        "Who made a difference in your day?",
        "What would you do differently today?",
        "How did you take care of yourself today?",
        "What emotion did you feel the most today?",
        "What drained your energy today?",
        "What gave you energy today?",
        "Did today feel meaningful to you? Why?",
        "What is something you need to forgive yourself for today?",
        "What small win did you overlook today?",
        "What moment do you want to remember from today?",
        "What distracted you the most today?",
        "What helped you stay calm today?",
        "What made you feel most like yourself today?",
        "What did you avoid today and why?",
        "What is something your future self would thank you for today?",
        "What thought stayed in your mind all day?",
        "What did today teach you about yourself?",
        "When did you feel most confident today?",
        "What made today harder than expected?",
        "What habit do you want to improve tomorrow?",
        "What are you currently overthinking?",
        "What is one thing you can let go of tonight?",
        "What conversation affected you the most today?",
        "What inspired you today?",
        "What made you feel appreciated today?",
        "What made you feel disconnected today?",
        "What are you looking forward to tomorrow?",
        "What would make tomorrow better?",
        "How would you describe today in three words?",
        "What was your most peaceful moment today?",
        "What did you do today that aligned with your goals?",
        "What is something you need more of in your life right now?",
        "What boundaries did you set or wish you had set today?",
        "What is one thing you want to remind yourself tonight?"
    ]
    
    static var current: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[dayOfYear % all.count]
    }
}
