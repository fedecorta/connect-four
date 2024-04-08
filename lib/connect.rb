class Board
    attr_accessor :grid, :remaining_guesses

    def initialize        
        @grid = Array.new(6) { Array.new(7) }
        @remaining_guesses = 42
    end

    def play_game
        game_result = nil
        until game_result = game_over?
            take_turns
            print_board
        end

        case game_result
        when :tie
            puts "Its a tie!"
        else
            winner = winner_symbol(game_result)
            puts "#{winner} wins"
        end
    end

    def take_turns
        selected_column = verify_input(0, 6)
        if @remaining_guesses.even? && full_column?(selected_column) == false
            add_disc(selected_column, "X")
            @remaining_guesses -= 1
        elsif @remaining_guesses.odd? && full_column?(selected_column) == false
            add_disc(selected_column, "O")
            @remaining_guesses -= 1
        else
            puts "That column is already full. Select another one."
        end
    end

    def print_board
        game_result = game_over?
        winning_coordinates = game_result.is_a?(Array) ? game_result : nil
        puts "\n Current Board:" 
        @grid.each_with_index do |row, row_index|
            row_str = row.map.with_index do |cell, col_index| 
                cell_representation = cell.nil? ? "." : cell
                if winning_coordinates && winning_coordinates.include?([row_index,col_index])
                    "\e[31m#{cell_representation}\e[0m"
                else
                    cell_representation
                end
            end.join(" ")
            puts "| #{row_str} |"
        end
        puts "\n"
    end

    def prompt_user
        print "\n Select Column Where You Want to Drop Disc (0-6): "
        input = gets.chomp
    end

    def verify_input(min, max)
        loop do
        user_input = prompt_user
        return user_input.to_i if user_input.to_i.between?(min, max)
        puts "Invalid option. Column out of range"
        end
    end

    def full_column?(column_index)
        @grid.all? { |row| row[column_index] != nil}
    end


    def add_disc(col_index, disc)
        row = @grid.rindex { |r| r[col_index].nil? }
        @grid[row][col_index] = disc if row
    end

    def game_over?
        horizontal_win = horizontal_win?
        vertical_win = vertical_win?
        diagonal_win = diagonal_win?
        return horizontal_win if horizontal_win
        return vertical_win if vertical_win
        return diagonal_win if diagonal_win
        return :tie if @remaining_guesses == 0
        false
    end

    def winner_symbol(winning_coordinates)
        @grid[winning_coordinates.first[0]][winning_coordinates.first[1]] unless winning_coordinates.nil?
    end

    def horizontal_win?
        @grid.each_with_index do |row, row_index|
            row.each_with_index do |cell, col_index|
                if col_index <= row.length-4
                    if (0..3).all? { |i| row[col_index + i] == cell && cell != nil}
                        return (0..3).map { |i| [row_index, col_index + i] }
                    end
                end
            end
        end
        nil
    end

    def vertical_win?
        @grid.each_with_index do |row, row_index|
            row.each_with_index do |cell, col_index|
                if row_index <= grid.length-4
                    if (0..3).all? { |i| @grid[row_index + i][col_index] == cell && cell != nil}
                        return (0..3).map { |i| [row_index + i, col_index] }
                    end
                end
            end
        end
        nil
    end

    def diagonal_win?
        @grid.each_with_index do |row, row_index|
            no_space_for_row = row_index > @grid.length - 4
            next if no_space_for_row
            row.each_with_index do |cell, col_index|
                if col_index <= row.length-4 && diagonal_match?(row_index, col_index, 1)
                        return winning_coordinates(row_index, col_index, 1)
                end
                if col_index >= 3 && diagonal_match?(row_index, col_index, -1)
                    return winning_coordinates(row_index, col_index, -1)
                end
            end
        end
        nil
    end

    def winning_coordinates(row_index, col_index, direction)
        (0..3).map { |i| [row_index + i, col_index + i * direction] }
    end
    
    def diagonal_match?(row_index, col_index, direction)
        cell = @grid[row_index][col_index]
        (0..3).all? { |i| @grid[row_index + i][col_index + i * direction] == cell && cell != nil}
    end

end
