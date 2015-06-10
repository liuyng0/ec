(topcoder-set-problem 
    '((language . cpp)
      (statement . "return the sum of the a array elements")
      (class-name . "Test1")
      (method-name . "testMethod")
      (params (("long" . 1) . "a")
              (("String" . 1) . "b")
              (("double" . 1) . "c")
              (("int" . 1) . "d")
              (("long" . 0) . "a1")
              (("String" . 0) . "b1")
              (("double" . 0) . "c1")
              (("int" . 0) . "d1"))
      (return "long" . 0)
      (signature . "long long testMethod(vector <long long> a, vector <string> b, vector <double> c, vector <int> d, long long a1, string b1, double c1, int d1)")
      (test-cases (("{1,2,3,4}" "{\"asdf\",\"qwer\"}" "{0.5,0.1}" "{0,1}"
                    "12345678901234" "\"zxcv\"" "1.234" "123")
                   . "10")
                  (("{11111111111,22222222222}" "{\"asdf\"}" "{0.5,0.3}" "{0,1}"
                    "12345678901234" "\"zxcv\"" "1.234" "123")
                   . "33333333333"))))
