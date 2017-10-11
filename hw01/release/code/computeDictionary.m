% Computes filter bank and dictionary, and saves it in dictionary.mat 

function computeDictionary()

	load('../data/traintest.mat'); 

    %{
    filterBank  = createFilterBank();
    img = imread('../data/computer_room/sun_aagspgyvjmoiytfb.jpg');
    extractFilterResponses(img, filterBank);
    %}
    
	interval= 1;
	train_imagenames = train_imagenames(1:interval:end);
	[filterBank,dictionary] = getFilterBankAndDictionary(strcat(['../data/'],train_imagenames));

	save('dictionary.mat','filterBank','dictionary'); 

end
