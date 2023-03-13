1. Place the "data job posts.csv" file in your chosen local working directory
2. Open "Data-preprocessing.R"
3. Adjust the working directory in this R-script.
4. Progress up to the big break in the R-script indicated by ###.
5. A new csv will be saved to the working directory (= "job_requirements_export.csv")m
6. Upload "job_requirements_export.csv" to your chosen google drive working directory.
7. Upload both .ipynb Notebooks to your google drive too, preferably in the same place where you saved the csv.
8. Open the "Annotate_unstructured_job_requirements.ipynb" Notebook on google colab, and adjust the working directory accordingly.
9. Follow the commented instructions on the first code block EXACTLY, otherwise spacy.load will throw an error.
10. Play through the notebook, a new csv will arrive in the working directory of your google drive (=annotations.csv).
11. Download this .csv file in your local R working directory you designated step 1.
12. Open "Data-preprocessing.R"
13. Progress from the big break in the R-script indicated by ###. Adjust the working directory again.
14. Let the whole code run from the ### section to the bottom of the script
15. A new dataset will arrive in your local R working directory (= "annotated_job_posts.csv")

-------- Short Path for just testing out the Neural Network ---------

16. Upload "annotated_job_posts.csv" to your chosen google drive working directory.
17. Open the "Neural Network Skill Classifier.ipynb" Notebook on google colab, and adjust the working directory accordingly.
18. Run through the code and test the Neural Network yourself! You can add or remove layers yourself! 
(choose from the commented out lines near the end of the notebook, but look at the syntax first, 
each layer has to be concatenated to the previous layer at the end of the code line)


Both JSON files also present in this folder are not that relevant. They are "by-products" of running the
"Annotate_unstructured_job_requirements.ipynb" Notebook.
