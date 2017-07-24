function new_obj = new(obj, pdf_id)

% create and return new pdf4D object
% copy patient, scan,session, and run IDs from obj

if nargin < 2
    pdf_id = 'new_pdf';
end

new_obj = obj;
new_obj = set(new_obj, 'pdfid', pdf_id);
new_obj.Header = new_header(new_obj);
