require 'csv'
require 'decisiontree'

module DTree
	class Create
	def initialize
	end
	def createDT
		attributes = ['mz','charge','A','R','N','D','B','C','E','Q','Z','G','H','I','L','K','M','F','P','S','T','W','Y','V']
		training = []
			CSV.foreach("testFastaFiles/testsmall.csv") do |row|
				data = row[0]
				row = data.split(/,/)
				row[1] = row[1].to_f
				row[2] = row[2].to_f
				row[3] = row[4].to_f
				row.delete_at(4)

				row << row[0].count("A")#A1
				row << row[0].count("R")#R2
				row << row[0].count("N")#N3
				row << row[0].count("D")#D4
				row << row[0].count("B")#B5
				row << row[0].count("C")#C6
				row << row[0].count("E")#E7
				row << row[0].count("Q")#Q8
				row << row[0].count("Z")#Z9
				row << row[0].count("G")#G10
				row << row[0].count("H")#H11
				row << row[0].count("I")#I12
				row << row[0].count("L")#L13
				row << row[0].count("K")#K14
				row << row[0].count("M")#M15
				row << row[0].count("F")#F16
				row << row[0].count("P")#P17
				row << row[0].count("S")#S18
				row << row[0].count("T")#T19
				row << row[0].count("W")#W20
				row << row[0].count("Y")#Y21
				row << row[0].count("V")#V22
				row = row[1..row.length]

				training<<row
			end	


		# Instantiate the tree, and train it based on the data (set default to '1')
		dec_tree = DecisionTree::ID3Tree.new(attributes, training, 1, :continuous)
		dec_tree.train
		#'A','R','N','D','B','C','E','Q','Z','G','H','I','L','K','M','F','P','S','T','W','Y','V'
		test = [844.43613,2,4,1,0,1,0,0,2,1,0,1,0,2,1,0,0,1,1,1,0,0,0,0]
		 
		generatedrt = dec_tree.predict(test)
		puts "Predicted: #{generatedrt} ... True decision: #{test.last}"
		puts "Actual: 60.007"
		return dec_tree
	end
	end
end
