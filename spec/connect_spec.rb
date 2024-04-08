require "./lib/connect"

describe Board do
  subject(:board) { described_class.new }

  describe '#initialize' do
    it 'creates a 7x6 grid' do
      expect(board.grid).to eq(Array.new(6) { Array.new(7) })
    end

    it 'has 42 guesses remaining' do
      expect(board.remaining_guesses).to eq(42)
    end
  end

  describe '#take_turns' do
    context 'when the column selected is not full' do
      before do
        allow(board).to receive(:gets).and_return("3\n", "3\n")
        2.times { board.take_turns }
      end

      it 'adds a disc to the correct column' do
        disc_in_last_row = board.grid[5][3] # Should be the bottom row if 3 is selected
        expect(disc_in_last_row).not_to be_nil
        disc_in_second_to_last_row = board.grid[4][3]
        expect(disc_in_second_to_last_row).not_to be_nil
      end

      it 'alternates turns between players' do
        # Assuming "X" goes first and then "O"
        disc_in_second_to_last_row = board.grid[4][3] # Should be "O" if "X" went first
        expect(disc_in_second_to_last_row).to eq("O")
      end
    end

    context 'when the column selected is full' do
      before do
        3.times do
          board.add_disc(3, "X")
          board.add_disc(3, "O")
        end
        allow(board).to receive(:gets).and_return("3\n")
        board.take_turns
      end

      it 'does not allow to add more discs to column' do
        full_column = board.grid.map { |row| row[3] } # Extract the full column
        expect(full_column).to eq(["O", "X", "O", "X", "O", "X"])
      end
    end
  end

  describe '#horizontal_win?' do
    context 'when there is a horizontal win on the board' do
      before do
        # Set up a horizontal win condition on the bottom row
        4.times { |i| board.grid[5][i] = "X" }
      end

      it 'detects a horizontal win' do
        expect(board.horizontal_win?).not_to be_nil
      end
    end
  end

  describe '#vertical_win?' do
    context 'when there is a vertical win on the board' do
      before do
        # Set up a vertical win condition
        4.times { |i| board.grid[i][0] = "O" }
      end

      it 'detects a vertical win' do
        expect(board.vertical_win?).not_to be_nil
      end
    end
  end

  describe '#diagonal_win?' do
    context 'when there is a diagonal win on the board' do
      before do
        # Set up a diagonal win condition
        4.times { |i| board.grid[i][i] = "O" }
      end

      it 'detects a diagonal win' do
        expect(board.diagonal_win?).not_to be_nil
      end
    end
  end

  describe '#game_over?' do
    context 'when there is a horizontal win' do
      before do
        4.times { |i| board.add_disc(i, "X") } # Simulate a winning condition
      end

      it 'detects the game is over with a win' do
        expect(board.game_over?).not_to be false
      end
    end

    context 'when the game is a tie' do
        before do
          # Example setup to fill the board in a pattern that avoids a win but fills all slots
          board.remaining_guesses = 0
        end
      
        it 'detects the game is over with a tie' do
          expect(board.game_over?).to eq(:tie)
        end
      end
  end
end
