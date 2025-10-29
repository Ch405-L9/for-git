/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/testimonial-05.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Testimonial05({ alt, ...rest }: Props) {
  return (
    <img
      src={String(src)}
      alt={alt ?? 'Testimonial 05'}
      loading="lazy"
      decoding="async"
      {...rest}
    />
  );
}
